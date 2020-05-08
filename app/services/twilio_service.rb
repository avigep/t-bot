# frozen_string_literal: true
class TwilioService
  def self.deliver(params)
    Rails.logger.info("Twilio Message with : #{params.to_json}")
    twilio_client.messages.create(
      from: params[:from],
      to: params[:to],
      body: params[:message]
    )
  end

  def self.deliver_menu(params)
    deliver(message: EmptyTarget.message, from: params[:from], to: params[:to])
  end

  def self.twilio_client
    @twilio_client ||= Twilio::REST::Client.new(ENV['wbot_twilio_account_sid'], ENV['wbot_twilio_auth_token'])
  end
end
