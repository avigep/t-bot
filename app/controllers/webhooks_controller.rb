class WebhooksController < ApplicationController
  skip_before_action  :verify_authenticity_token
  def whatsapp
    Rails.logger.info("Incoming -> Whatsapp -> params : #{params.inspect}")
    from = params['To']
    to = params['From']
    twilio.messages.create(
      from: from,
      to: to,
      body: "Registered"
    )
    render json: {'Message': 'OK'}
  end

  private

  def twilio
    @twilio ||= Twilio::REST::Client.new(ENV['twilio_account_sid'], ENV['twilio_auth_token'])
  end
end
