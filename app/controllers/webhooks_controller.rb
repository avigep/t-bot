class WebhooksController < ApplicationController
  skip_before_action  :verify_authenticity_token

  def whatsapp
    Rails.logger.info("Incoming -> Whatsapp -> params : #{params.inspect}")
    response = InterpreterService.new(params).execute_with_response
    render json: response
  end
end
