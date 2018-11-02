class TwilioService
  def self.deliver(params)
    self.twilio_client.messages.create(
      from: params[:to],
      to: params[:from],
      body: message_body(params)
      )
  end

  private

  def self.message_body(params)
    params[:result] == :success ? "```Transaction saved.\n\n₹```*#{params[:target].amount}* ```\n\nfrom``` *#{params[:target].from.name.capitalize}* ```\n\nto``` *#{params[:target].to.name.capitalize}*" : "```Fail to save transaction. ```"
  end

  def self.twilio_client
    @twilio ||= Twilio::REST::Client.new(ENV['twilio_account_sid'], ENV['twilio_auth_token'])
  end

end
