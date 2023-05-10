class ExampleController < ApplicationController
  def message
    render json: { message: "Hello from the Rails API!" }
  end
end