class TransactionAddJob < ApplicationJob
  queue_as :default

  DEFAULT_SENDER = 'whatsapp:+14155238886'.freeze
  FAIL_MESSAGE = '```fail to add transaction.```' .freeze
  SUCCESS_MESSAGE = "```Transaction saved.\n\n``` *₹_AMOUNT_*\n\n *_FROM_* ==> *_TO_*".freeze

  def initialize(params)
    @params = params
    @transaction_params = transaction_attributes
    @transaction = nil
    @notification_params = { type: :add_transaction, transaction: nil, result: :fail, message: FAIL_MESSAGE}
  end

  def perform(*_args)
    @transaction = Transaction.create(@transaction_params)
    if @transaction.save!
      @notification_params[:result] = :success
      @notification_params[:message] = SUCCESS_MESSAGE
                                       .gsub('_AMOUNT_', @transaction.amount.to_s)
                                       .gsub('_FROM_', @transaction.from.name.capitalize)
                                       .gsub('_TO_', @transaction.to.name.capitalize)
    end

    send_notification
    { status: @notification_params[:result] }
  end

  private

  def send_notification
    initiator_contact = "whatsapp:#{@transaction.to.contact_numbers.first}"
    target_contact = "whatsapp:#{@transaction.from.contact_numbers.first}"

    # Send notification to initiator
    TwilioService.deliver(
      {
        type: :transaction,
        target: :initiator,
        transaction: @transaction,
        from: DEFAULT_SENDER,
        to: initiator_contact,
        message: @notification_params[:message]
      }
    )

    # Send notification to target
    TwilioService.deliver(
      {
        type: :transaction,
        target: :traget,
        transaction: @transaction,
        from: DEFAULT_SENDER,
        to: target_contact,
        message: @notification_params[:message]
      }
    )
  end

  def transaction_attributes
    case @params[:intent]
    when :incoming_transaction
      to = Member.find_by(contact_numbers: @params[:raw_params]['From'].split(':').last)
      from = Member.find_or_create_by(name: @params[:target_name])
    when :outgoing_transaction
      to = Member.find_or_create_by(name: @params[:target_name])
      from = Member.find_by(contact_numbers: @params[:raw_params]['From'].split(':').last)
    else
      to = nil
      from = nil
    end
    {
      to: to,
      from: from,
      amount: @params[:amount],
      notes: @params[:notes]
    }
  end
end