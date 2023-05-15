require 'test_helper'

class ExampleControllerTest < ActionDispatch::IntegrationTest
  test "should get message" do
    get example_message_url
    assert_response :success
    json_response = JSON.parse(@response.body)
    assert_equal 'Hello from the Rails API!', json_response['message']
  end
end