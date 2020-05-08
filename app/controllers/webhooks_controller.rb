class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def whatsapp
    Rails.logger.info("Incoming -> Whatsapp -> params : #{params.inspect}")
    response = if params[:MediaContentType0].present?
                 MediaInterpreterService.new(params).execute
               else
                 TextInterpreterService.new(params).execute
               end
    render json: response
  end
end
