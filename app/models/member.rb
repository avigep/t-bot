class Member
  # TODO: add validations
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :email, type: String
  field :contact_numbers, type: Array, default: []

  has_many :lent_transactions, class_name: 'Transaction', inverse_of: :lender
  has_many :borrowed_transactions, class_name: 'Transaction', inverse_of: :borrower

end
