class Co2Notify::Status
  class Base
    attr_reader :co2, :config, :previous
    delegate :timeout, :cooldown, :mention, :user, to: :config

    def initialize(config, previous = nil, co2 = nil)
      @config, @co2, @previous = config, co2, previous
    end

    private

    def hc_mention
      "@#{mention} " if mention.present?
    end

    def hc_user
      "@#{user} " if user.present?
    end
  end

  class VeryHigh < Base
    def message
      "#{hc_mention}CO₂ level is very high - #{co2}. Please open the windows!"
    end

    def color
      :red
    end

    def changed?(new_status)
      new_status.is_a?(Empty) ||
        new_status.is_a?(Normal) ||
        (new_status.is_a?(VeryHigh) && new_status.co2 > co2)
    end

    def timeout
      previous.is_a?(Empty) || previous.is_a?(Normal) ? cooldown : super
    end
  end

  class High < Base
    def message
      "#{hc_mention}CO₂ level is high - #{co2}. Please open the windows!"
    end

    def color
      previous.is_a?(High) ? :red : :yellow
    end

    def changed?(new_status)
      new_status.is_a?(Empty) ||
        new_status.is_a?(Normal) ||
        (new_status.is_a?(High) && new_status.co2 > co2)  ||
        new_status.is_a?(VeryHigh)
    end

    def timeout
      previous.is_a?(Empty) || previous.is_a?(Normal) ? cooldown : super
    end
  end

  class Normal < Base
    def message
      "#{hc_mention}CO₂ level is normalized - #{co2}. You can close the windows."
    end

    def color
      :green
    end

    def changed?(new_status)
      new_status.is_a?(Empty) || new_status.is_a?(High) || new_status.is_a?(VeryHigh)
    end

    def timeout
      previous.is_a?(High) || previous.is_a?(VeryHigh) ? cooldown : super
    end
  end

  class Empty < Base
    def message
      "#{hc_user}Please check that CO₂ monitor is connected."
    end

    def color
      :purple
    end

    def changed?(new_status)
      new_status.is_a?(Empty) || new_status.is_a?(High) || new_status.is_a?(VeryHigh)
    end
  end

  def self.build(co2, config, previous = nil)
    case co2
    when 1..config.high_level
      Normal.new(config, previous, co2)
    when config.high_level..config.very_high_level
      High.new(config, previous, co2)
    when proc { |n| n >= config.very_high_level }
      VeryHigh.new(config, previous, co2)
    else
      Empty.new(config)
    end
  end
end
