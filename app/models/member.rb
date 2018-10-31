class Member
  # TODO: add validations
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :email, type: String
  field :contact_numbers, type: Array, default: []
end
