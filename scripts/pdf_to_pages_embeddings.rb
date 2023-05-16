require "dotenv"
require "pdf-reader"
require "csv"
require "openai"

require 'blingfire' 

Dotenv.load('.env')

@MODEL_NAME = "ada"
@DOC_EMBEDDINGS_MODEL = "text-search-#{@MODEL_NAME}-doc-001"

# Set OpenAI API key
OpenAIClient = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

# Initialize GPT-2 tokenizer
@tokenizer = BlingFire::Model.new

def count_tokens(text)
  # Count the number of tokens in a string

  puts "tokenizer encoded length: "
  puts @tokenizer.text_to_words(text).length

  @tokenizer.text_to_words(text).length
end

def extract_pages(page_text, index)
  # Extract the text from the page
  return [] if page_text.length == 0

  content = page_text.split.join(" ")
  puts "page text: " + content
  outputs = [["Page " + index.to_s, content, count_tokens(content) + 4]]

  outputs
end

filename = ARGV[0]

puts "filename: " + filename

reader = PDF::Reader.new(filename)

res = []
i = 1
reader.pages.each do |page|
  res += extract_pages(page.text, i)
  i += 1
end

df = res.select { |row| row[2] < 2046 }

CSV.open("#{filename}.pages.csv", 'w') do |csv|
  csv << ["title", "content", "tokens"]
  df.each do |row|
    csv << row
  end
end

def get_embedding(text, model)
  result = OpenAIClient.embeddings(
      parameters: {
        model: model,
        input: text
      }
    )

  result["data"][0]["embedding"]
end

def get_doc_embedding(text)
  get_embedding(text, @DOC_EMBEDDINGS_MODEL)
end

def compute_doc_embeddings(df)
  df.map.with_index { |row, idx| [idx, get_doc_embedding(row[1])] }.to_h
end

doc_embeddings = compute_doc_embeddings(df)

CSV.open("#{filename}.embeddings.csv", 'w') do |csv|
  csv << ["title"] + (0..4095).to_a
  doc_embeddings.each do |i, embedding|
    csv << ["Page " + (i + 1).to_s] + embedding
  end
end
