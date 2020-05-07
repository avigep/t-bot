class TransactionNotificationJob < ApplicationJob
  queue_as :default
 
  attr_accessor :transaction, :twillio_number

  def initialize(transaction)
    @transaction = transaction
    @twillio_number = 'whatsapp:+14155238886'
    super
  end

  def perform(*args)

    initiator_contact = "whatsapp:#{transaction.to.contact_numbers.first}"
    target_contact = "whatsapp:#{transaction.from.contact_numbers.first}"

    # Send notification to initiator
    TwilioService.deliver(
      {
        type: :transaction,
        target: :initiator,
        transaction: transaction,
        from: twillio_number,
        to: initiator_contact
      }
    )

    # Send notification to target
    TwilioService.deliver(
      {
        type: :transaction,
        target: :traget,
        transaction: transaction,
        from: twillio_number,
        to: target_contact
      }
    )
  end
end
