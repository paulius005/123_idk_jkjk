class QuestionsController < ApplicationController
  
  require "openai"
  require 'csv'
  require 'httparty'
  require 'json'


  def initialize
    super

    # Add your API keys and other configurations here
    @openai_api_key = ENV["OPENAI_API_KEY"]
    @resemble_api_key = ""
    @model_name = "curie"
    @doc_embeddings_model = "text-search-#{@model_name}-doc-001"
    @query_embeddings_model = "text-search-#{@model_name}-query-001"
    @completions_model = "text-davinci-003"

    # Load dataframes
    @df = CSV.read(Rails.root.join('app', 'data', 'product_engineering_challenge.pdf.pages.csv'), headers: true)
    @document_embeddings = load_embeddings(Rails.root.join('app', 'data', 'product_engineering_challenge.pdf.embeddings.csv'))
    @OpenAIClient = OpenAI::Client.new(access_token: @openai_api_key)
  end

  def index
    @default_question = "What is this book about?"
  end

  def show
    question = Question.find(params[:id])
    render json: { question: question.question, answer: question.answer, audio_src_url: question.audio_src_url, id: question.id }
  end

  def ask
    question_asked = params[:question]

    question_asked += '?' unless question_asked.ends_with?('?')

    previous_question = Question.find_by(question: question_asked)
    audio_src_url = previous_question.present? ? previous_question.audio_src_url : nil

    if audio_src_url.present?
      puts "previously asked and answered: #{previous_question.answer} (#{previous_question.audio_src_url})"
      previous_question.increment!(:ask_count)
      render json: { question: previous_question.question, answer: previous_question.answer, audio_src_url: audio_src_url, id: previous_question.id }
    elsif previous_question.present? && !audio_src_url.present?
      puts "previously asked and answered: #{previous_question.answer} (#{previous_question.audio_src_url})"
      previous_question.increment!(:ask_count)

      # Resmbemle.ai goes here, should output audio_src_url

      render json: { question: previous_question.question, answer: previous_question.answer, audio_src_url: nil, id: previous_question.id }
    else
      answer, context = answer_query_with_context(question_asked, @df, @document_embeddings)

      # Resmbemle.ai goes here, should output audio_src_url

      question = Question.create!(
        question: question_asked,
        answer: answer,
        context: context,
        audio_src_url: nil
      )

      render json: { question: question.question, answer: answer, audio_src_url: question.audio_src_url, id: question.id }
    end
  end

  private

  # Helper methods

  def answer_query_with_context(query, df, document_embeddings)
    prompt, context = construct_prompt(query, document_embeddings, df)
  
    puts "===\n", prompt
  
    completions_model = "text-davinci-003"

  
    response = @OpenAIClient.completions(
      parameters: {
        temperature: 0.0,
        max_tokens: 150,
        model: completions_model,
        prompt: prompt,
      }
    )

    puts "===\n", response
    puts "===\n", response["choices"]
    puts "===\n", response["choices"][0]["text"]

    answer = response["choices"][0]["text"]
    return answer, context.join
  end

  def get_document_section_by_title(title)
    result = nil
    CSV.foreach(Rails.root.join('app', 'data', 'product_engineering_challenge.pdf.pages.csv'), headers: true) do |row|
      if row['title'] == title
        result = row
        break
      end
    end

    result
  end

  def construct_prompt(question, context_embeddings, df)
    most_relevant_document_sections = order_document_sections_by_query_similarity(question, context_embeddings)
  
    chosen_sections = []
    chosen_sections_len = 0
    chosen_sections_indexes = []
  
    separator = "\n* "
    separator_len = 3
    max_section_len = 500

    puts "most_relevant_document_sections: #{most_relevant_document_sections}"
  
    most_relevant_document_sections.each do |section|
      section_index = section[:title]

      document_section = get_document_section_by_title(section_index)
  
      chosen_sections_len += document_section['tokens'].to_i + @separator_len
      if chosen_sections_len > max_section_len
        space_left = max_section_len - chosen_sections_len - separator.length
        chosen_sections.append(separator + document_section['content'][0...space_left])
        chosen_sections_indexes.append(section_index.to_s)
        break
      end
  
      chosen_sections.append(separator + document_section['content'])
      chosen_sections_indexes.append(section_index.to_s)
    end
  
    header = """Sahil Lavingia is the founder and CEO of Gumroad, this is an interview exercise designed by him. Please keep your answers to three sentences maximum, and speak in complete sentences. Stop speaking once your point is made.\n\n"""
  
    prompt = header + chosen_sections.join + "\n\n\nQ: " + question

    return prompt, chosen_sections_indexes
  end

  def load_embeddings(fname)
    data = {}
    CSV.foreach(fname, headers: true) do |row|
      data[row['title']] = row[1..-1].map(&:to_f)
    end

    data
  end

  def get_embedding(text, model)
    result = @OpenAIClient.embeddings(
      parameters: {
        model: model,
        input: text
      }
    )

    result["data"][0]["embedding"]
  end

  def get_doc_embedding(text)
    get_embedding(text, @doc_embeddings_model)
  end

  def get_query_embedding(text)
    get_embedding(text, @query_embeddings_model)
  end

  def vector_similarity(x, y)
    x.zip(y).map { |a, b| a * b }.sum(0)
  end

  def order_document_sections_by_query_similarity(question, context_embeddings)

    query_embedding = get_query_embedding(question)

    similarity_scores = context_embeddings.map do |title, doc_embedding|
      similarity = vector_similarity(query_embedding, doc_embedding)
      { title: title, similarity: similarity }
    end

    sorted_similarity_scores = similarity_scores.sort_by { |score| -1 * score[:similarity] }
  
    sorted_similarity_scores
  end
end