class WebhooksController < ApplicationController
  skip_before_action  :verify_authenticity_token

  def whatsapp
    Rails.logger.info("Incoming -> Whatsapp -> params : #{params.inspect}")
    @interpreter = InterpreterService.new(params)
    render json: @interpreter.execute_with_response
  end
end
