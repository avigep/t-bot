class MemberAddJob < ApplicationJob
  queue_as :default

  DEFAULT_SENDER = 'whatsapp:+14155238886'.freeze
  FAIL_MESSAGE = '```fail to add member.```' .freeze
  SUCCESS_MESSAGE = '```Member``` *_NAME_* ```added successfully.```'.freeze

  def initialize(params)
    @params = params
    @raw_vcard = RestClient.get(@params[:media_link]).body
    @member_params = parse_vcard
    @notification_params = {
      type: :add_member, member: nil,
      result: :fail, to: params[:added_by],
      from: DEFAULT_SENDER, message: FAIL_MESSAGE
    }
    super
  end

  def perform(*_args)
    member = Member.find_or_create_by(@member_params)
    @notification_params[:member] = member
    if member.save!
      @notification_params[:result] = :success
      @notification_params[:message] = SUCCESS_MESSAGE.gsub('_NAME_', member.name)
    end
    TwilioService.deliver(@notification_params)
  end

  private

  def parse_vcard
    member_params = { name: nil, contact_numbers: [] }
    @raw_vcard.lines.each do |line|
      line.chomp!
      prop, value = line.split(':')
      member_params[:name] = value if prop == 'FN'
      member_params[:contact_numbers] << value if prop.start_with?('tel;')
    end
    member_params
  end
end
