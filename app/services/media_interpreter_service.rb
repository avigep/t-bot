class MediaInterpreterService
  def initialize(params)
    @type = params['MediaContentType0']
    @params = params
  end

  def execute_with_response
    resp = case @type
           when 'text/vcard'
             MemberAddJob.new(member_params).perform
           else
             Rails.logger.error("Unknow MediaContentType0: #{@params.inspect}")
             "Unsupported MediaContentType0 #{@params.to_json}"
           end
    { status: resp }
  end

  private

  def member_params
    {
      type: :vcard,
      media_link: @params['MediaUrl0'],
      added_by: @params['From']
    }
  end
end
