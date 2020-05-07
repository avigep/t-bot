class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def whatsapp
    Rails.logger.info("Incoming -> Whatsapp -> params : #{params.inspect}")
    if params[:MediaContentType0].present?
      response = MediaInterpreterService.new(params).execute_with_response
    else
      response = TextInterpreterService.new(params).execute_with_response
    end
    render json: response
  end
end
