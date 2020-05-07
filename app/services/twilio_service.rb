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
      # params[:result] == :success ? "```Transaction saved.\n\n``` *₹#{params[:transaction].amount}*\n\n *#{params[:transaction].from.name.capitalize}* ==> *#{params[:target].to.name.capitalize}*" : "```Fail to save transaction. ```"
      # Assuming result is success that is why notification is triggered
      if params[:target] == :initiator
        "```Transaction saved.\n\n``` *₹#{params[:transaction].amount}*\n\n *#{params[:transaction].from.name.capitalize}* ==> *#{params[:transaction].to.name.capitalize}*"
      else
        "```Transaction Added by #{params[:transaction].to.name}.\n\n``` *₹#{params[:transaction].amount}*\n\n *#{params[:transaction].from.name.capitalize}* ==> *#{params[:transaction].to.name.capitalize}*"
      end
    when :report_daily
      params[:message]
    when :add_member
      if params[:result] == :success
        "```Member``` *#{params[:member].name}* ```added successfully.```"
      else
        '```fail to add member.```'
      end
    else
      params[:message]
    end
  end

  def self.twilio_client
    @twilio ||= Twilio::REST::Client.new(ENV['wbot_twilio_account_sid'], ENV['wbot_twilio_auth_token'])
  end

end