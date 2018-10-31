class Transaction
  include Mongoid::Document
  include Mongoid::Timestamps

  field :notes, type: String
  field :type, type: String
  field :amount, type: Integer

  belongs_to :from, class_name: 'Member', inverse_of: :from_transactions
  belongs_to :to, class_name: 'Member', inverse_of: :to_transactions

end
