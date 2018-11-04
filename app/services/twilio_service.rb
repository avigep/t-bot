class TwilioService
  def self.deliver(params)
    Rails.logger.info("Twilio Message with : #{params.to_json}")
    # TODO get message from caller
    self.twilio_client.messages.create(
      from: params[:from],
      to: params[:to],
      body: message_body(params)
      )
  end

  private

  def self.message_body(params)
    case params[:type]
    when :transaction
      params[:result] == :success ? "```Transaction saved.\n\n``` *₹#{params[:target].amount}*\n\n *#{params[:target].from.name.capitalize}* ==> *#{params[:target].to.name.capitalize}*" : "```Fail to save transaction. ```"
    when :report_daily
      params[:message]
    else
      params[:message]
    end
  end

  def self.twilio_client
    @twilio ||= Twilio::REST::Client.new(ENV['twilio_account_sid'], ENV['twilio_auth_token'])
  end

end