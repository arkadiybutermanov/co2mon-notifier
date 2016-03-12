class Co2Notify::Notifier
  def self.start
    new(Co2Notify::Config.get).start
  end

  attr_reader :config, :client, :status
  delegate :timeout, to: :status

  def initialize(config)
    @config = config
    @client = Co2Notify::HipchatClient.new(config)
    @status = Co2Notify::Status::Empty.new(config)
  end

  def start
    loop do
      notify
      sleep timeout * 60
    end
  rescue Interrupt
  end

  private

  def get_data
    Co2mon.get_data[:co2]
  end

  def notify
    new_status = Co2Notify::Status.build(get_data, config, status)

    if status.changed?(new_status)
      client.send(new_status)
      @status = new_status
    end
  end
end
