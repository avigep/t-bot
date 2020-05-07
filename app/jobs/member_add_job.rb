class MemberAddJob < ApplicationJob

  queue_as :default

  def initialize(params)
    @params = params
    super
  end

  def perform(*args)
    member_params = { contact_numbers: [] }
    raw_vcard = RestClient.get(@params[:media_link]).body
    raw_vcard.lines.each do |line|
      line.chomp!
      prop, value = line.split(':')
      member_params[:name] = value if prop == 'FN'
      if ['tel;type=work;type=pre', 'tel;type=cell', 'tel;type=home', 'tel;type=work'].include?(prop.downcase!)
        member_params[:contact_numbers] << value
      end
    end
    Member.create!(member_params)
  end
end