class DailyReportJob < ApplicationJob
  queue_as :default
  attr_accessor :target, :params, :result

  #after_perform :send_twilio_notification

  def initialize(params)
    @params = params
    super
  end

def perform(*args)
  # TODO deal with nil transactions
  member = Member.find_by(contact_numbers: @params[:to].split(':').last)
  form_transactions = Transaction.where(
    {:created_at => { '$gt' => DateTime.now.beginning_of_day}}
    ).and({:from=> member})

    to_transactions = Transaction.where(
      {:created_at => { '$gt' => DateTime.now.beginning_of_day}}
      ).and({:to=> member})
      # TODO handle result
      @result = :success
      #@result = form_transactions.blank? && from_transactions.blank? ? :fail : :success
      @target = {
        summary: {
          total_outgoing: form_transactions.pluck(:amount).inject(:+),
          total_incoming: to_transactions.pluck(:amount).inject(:+)
        },
        details: {
          outgoing: form_transactions,
          incoming: to_transactions
        }

      }
      send_twilio_notification
      @result
    end

  private

  def send_twilio_notification
    message = "```Daily Summary```\n"
    message << "----------------------------\n"
    message << "*Total outgoing: ₹#{@target[:summary][:total_outgoing]}*\n"
    message << "*Total incoming: ₹#{@target[:summary][:total_incoming]}*\n"
    message << "----------------------------\n"
    message << @target[:details][:outgoing].map{|t| "₹#{t.amount}  #{t.from.name.capitalize} ==> #{t.to.name.capitalize}\n"}.join('')
    message << @target[:details][:incoming].map{|t| "₹#{t.amount}  #{t.from.name.capitalize} <== #{t.to.name.capitalize}\n"}.join('')
    TwilioService.deliver(
      {
        type: :report_daily,
        result: @result,
        target: @target,
        message: message,
        from: @params[:from],
        to: @params[:to]
      }
    )
  end

end
