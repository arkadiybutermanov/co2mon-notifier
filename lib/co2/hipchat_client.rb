class Co2::HipchatClient
  attr_reader :client, :config
  delegate :room, :location, :api_token, to: :config

  def initialize(config)
    @config = config
    @client = HipChat::Client.new(api_token, api_version: "v2")
  end

  def send(status)
    client[room].send("Co2 (#{location})", status.message, color: status.color, message_format: "text")
  end
end
