# frozen_string_literal: true

class TwilioService
  def self.deliver(params)
    Rails.logger.info("Twilio Message with : #{params.to_json}")
    # TODO: get message from caller
    twilio_client.messages.create(
      from: params[:from],
      to: params[:to],
      body: message_body(params)
    )
  end

  private

  def self.message_body(params)
    case params[:type]
    when :transaction
      if params[:target] == :initiator
        "```Transaction saved.\n\n``` *₹#{params[:transaction].amount}*\n\n *#{params[:transaction].from.name.capitalize}* ==> *#{params[:transaction].to.name.capitalize}*"
      else
        "```Transaction Added by #{params[:transaction].to.name}.\n\n``` *₹#{params[:transaction].amount}*\n\n *#{params[:transaction].from.name.capitalize}* ==> *#{params[:transaction].to.name.capitalize}*"
      end
    when :report_daily, :add_member
      params[:message]
    else
      params[:message]
    end
  end

  def self.twilio_client
    @twilio ||= Twilio::REST::Client.new(ENV['wbot_twilio_account_sid'], ENV['wbot_twilio_auth_token'])
  end
end
