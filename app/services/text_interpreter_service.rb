class TextInterpreterService
  def initialize(params)
    @wit_response = wit_client.message(params['Body'])
    @intent = @wit_response['entities']['intent'].first['value'].to_sym rescue nil
    @params = params
    @result = nil
  end

  def execute_with_response
    @result = case @intent
              when :incoming_transaction, :outgoing_transaction
                transaction = {
                  target_name: @wit_response['entities']['contact'].first['value'].downcase,
                  amount: @wit_response['entities']['number'].first['value'],
                  notes: @wit_response['_text'],
                  intent: @intent,
                  raw_params: @params
                }
                TransactionAddJob.new(transaction).perform
              when :report_daily
                # TODO add contact as param
                DailyReportJob.new({to: @params['From'], from: @params['To'], contact: ''}).perform
              else
                # TODO move to twilio service
                TwilioService.deliver(
                  {
                     type: :undefined,
                     result: :fail,
                     message: EmptyTarget.message,
                     from: @params['To'],
                     to: @params['From']
                  }
                )
                :fail
              end
    { "message": @result.to_s }
  end

  private

  def transaction_handler
    transaction = Transaction.new(transaction_attributes)
    result = transaction.save! ? :success : :fail
    if result == :success
      TransactionNotificationJob.new(transaction).perform
    else
      Rails.logger.error("Error saving transaction:  #{transaction.errors}")
    end
    result
    # transaction = Transaction.new(transaction_attributes)
    # result = transaction.save! ? :success : :fail
    # TwilioService.deliver(
    #   {
    #     type: :transaction,
    #     result: result,
    #     target: transaction,
    #     from: @params['To'], # Yes I know!
    #     to: "whatsapp:#{transaction.from.contact_numbers.first}"
    #   }
    # )

    # TwilioService.deliver(
    #   {
    #     type: :transaction,
    #     result: result,
    #     target: transaction,
    #     from: @params['To'],
    #     to: "whatsapp:#{transaction.to.contact_numbers.first}"
    #   }
    # )
    # result
  end

  def transaction_attributes
    case @intent.to_sym
    when :incoming_transaction
     to = Member.find_by(contact_numbers: @params['From'].split(':').last)
     from = Member.find_or_create_by(name: @wit_response['entities']['contact'].first['value'].downcase)
    when :outgoing_transaction
     to = Member.find_or_create_by(name: @wit_response['entities']['contact'].first['value'].downcase)
     from = Member.find_by(contact_numbers: @params['From'].split(':').last)
    else
      to = nil
      form = nil
    end
    {
      to: to,
      from: from,
      amount: @wit_response['entities']['number'].first['value'],
      notes: @wit_response['_text']
    }
  end

  def wit_client
    @wit ||= Wit.new(access_token: ENV['wbot_wit_access_token'])
  end

end
