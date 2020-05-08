class TextInterpreterService
  def initialize(params)
    @wit_response = wit_client.message(params['Body'])
    @intent = @wit_response['entities']['intent'].first['value'].to_sym rescue nil
    @params = params
    @result = nil
  end

  def execute
    @result = case @intent
              when :incoming_transaction, :outgoing_transaction
                TransactionAddJob.new(transaction_params).perform
              when :report_daily
                DailyReportJob.new(daily_report_params).perform
              else
                TwilioService.deliver_menu(from: @params['To'], to: @params['From'])
                :fail_served_menu
              end
    { "response": @result.to_s }
  end

  private

  def daily_report_params
    { to: @params['From'], from: @params['To'] }
  end

  def transaction_params
    {
      target_name: @wit_response['entities']['contact'].first['value'].downcase,
      amount: @wit_response['entities']['number'].first['value'],
      notes: @wit_response['_text'],
      intent: @intent,
      raw_params: @params
    }
  end

  def wit_client
    @wit ||= Wit.new(access_token: ENV['wbot_wit_access_token'])
  end
end
