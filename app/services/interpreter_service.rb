class InterpreterService
  def initialize(params)
    @wit_response = wit_client.message(params['Body'])
    @intent = @wit_response['entities']['intent'].first['value'].to_sym rescue nil
    @params = params
    #@entities = build_entities
  end

  def execute_with_response
    target = case @intent
    when :incoming_transaction, :outgoing_transaction
      Transaction.new(transaction_attributes)
    else
      EmptyTarget.new
    end
    result = target.save! ? :success : :fail
    # TODO : add flag for sending reply
    TwilioService.deliver(
      { result: result,
        target: target,
        from: @params['To'], # Yes I know!
        to: @params['From']
      }
    )
    {"message": result.to_s}
  end

  private

  def transaction_attributes
    case @intent.to_sym
    when :incoming_transaction
     to = Member.find_by(contact_numbers: @params['From'].split(':').last)
     from = Member.find_or_create_by(name: @wit_response['entities']['contact'].first['value'])
    when :outgoing_transaction
     to = Member.find_or_create_by(name: @wit_response['entities']['contact'].first['value'])
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
    @wit ||= Wit.new(access_token: ENV['wit_access_token'])
  end

end
