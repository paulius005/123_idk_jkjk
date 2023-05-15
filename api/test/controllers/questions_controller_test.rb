require 'test_helper'

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @question = questions(:one)
    @new_question = "New unique question - #{SecureRandom.uuid}?"
  end

  test 'should create question' do
    assert_difference('Question.count') do
      post questions_ask_url, params: { question: @new_question }, as: :json
    end

    puts "Response body: #{@response.body}"
    puts "Response status: #{@response.status}"

    assert_response 200
  end

  test 'should show question' do
    get question_url(@question), as: :json
    assert_response :success
  end

  test 'should update question if it was previously asked' do
    question_count = @question.ask_count
  
    post questions_ask_url, params: { question: @question.question }, as: :json

    @question.reload

    assert_equal question_count + 1, @question.ask_count
  end
end