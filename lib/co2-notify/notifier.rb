class Co2Notify::Notifier
  def self.start
    new(Co2Notify::Config.get).start
  end

  attr_reader :config, :client, :status
  delegate :timeout, to: :status

  NORMALIZATION_CONSTANT = 10000.0.freeze

  def initialize(config)
    @config = config
    @client = Co2Notify::HipchatClient.new(config)
    @status = Co2Notify::Status::Empty.new(config, Time.now)
  end

  def start
    loop do
      time = Time.now

      if time > start_time && time < stop_time
        notify
      end

      sleep timeout * 60
    end
  rescue Interrupt
  end

  private

  def get_data
    Co2mon.get_data[:co2]
  end

  def notify
    new_status = Co2Notify::Status.build(get_data, Time.now, config, status)

    if status.changed?(new_status)
      client.send(new_status)
      @status = new_status

      if status.type_changed?
        fann = if File.exist?(Co2Notify::Config.fann_path)
          RubyFann::Standard.new(filename: Co2Notify::Config.fann_path)
        else
          RubyFann::Shortcut.new(num_inputs: 2, num_outputs: 1)
        end

        train = RubyFann::TrainData.new(
          inputs: [
            [
              (status.co2 - (status.previous.co2 || 0)) / NORMALIZATION_CONSTANT,
              status.time.hour / 100.0
            ]
          ],
          desired_outputs: [
            [
              (status.time - status.previous.time) / NORMALIZATION_CONSTANT
            ]
          ]
        )

        fann.train_on_data(train, 1000, 10, 0.01)
        fann.save(Co2Notify::Config.fann_path)
      end
    end
  end

  def start_time
    Time.parse(config.start_time)
  end

  def stop_time
    Time.parse(config.stop_time)
  end
end
