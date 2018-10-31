class Member
  # TODO: add validations
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :email, type: String
  field :contact_numbers, type: Array, default: []

  has_many :from_transactions, class_name: 'Transaction', inverse_of: :from
  has_many :to_transactions, class_name: 'Transaction', inverse_of: :to

end
