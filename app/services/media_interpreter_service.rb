class MediaInterpreterService
  def initialize(params)
    @type = params['MediaContentType0']
    @params = params
  end

  def execute_with_response
    case @type
    when 'text/vcard'
      member_params = {
        type: :vcard,
        media_link: @params['MediaUrl0']
      }
      MemberAddJob.new(member_params).perform
    else
      Rails.logger.error("Unknow MediaContentType0: #{@parms.inspect}")
    end
  end
end