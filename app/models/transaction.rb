class Transaction
  include Mongoid::Document
  include Mongoid::Timestamps

  field :notes, type: String
  field :type, type: String
  field :amount, type: Integer

  belongs_to :lender, class_name: 'Member', inverse_of: :lent_transactions
  belongs_to :borrower, class_name: 'Member', inverse_of: :borrowed_transactions
  
end
