class WebhooksController < ApplicationController
  skip_before_action  :verify_authenticity_token
  def whatsapp
    Rails.logger.info("Incoming -> Whatsapp -> params : #{params.inspect}")

    if save_transaction?
      render json: {'Message': 'OK'}
    else
      render json: {'Message': 'FAIL'}
    end
  end

  private

  # TODO: write service for this
  def save_transaction?
    message = params['Body'].split(' ')
    to = message[1].downcase == 'to' ? Member.find_by(name: message[2]) : Member.find_by(contact_numbers: params['From'].split(':').last)
    from = message[1].downcase == 'from' ?  Member.find_by(name: message[2]) : Member.find_by(contact_numbers: params['From'].split(':').last)
    transaction = Transaction.new(from: from, to: to)
    transaction.amount = message[0]
    transaction.notes = params['Body'].downcase.split('for').last
    twilio.messages.create(
      from: params['To'],
      to: params['From'],
      body: "```Registered ₹```*#{transaction.amount}* ```from``` *#{transaction.from.name.capitalize}* ```to``` *#{transaction.to.name.capitalize}*"
    )
    transaction.save!
  end

  def twilio
    @twilio ||= Twilio::REST::Client.new(ENV['twilio_account_sid'], ENV['twilio_auth_token'])
  end
end
