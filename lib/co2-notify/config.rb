require "yaml"

class Co2Notify::Config < OpenStruct
  CONFIG_DIR = ".co2-notify".freeze
  CONFIG_FILE_NAME = "config.yml".freeze
  OUTPUT_FILE_NAME = "output.log".freeze
  ERROR_FILE_NAME = "error.log".freeze
  DEFAULT_TIMEOUT = 5.freeze
  DEFAULT_COOLDOWN = 15.freeze
  DEFAULT_HIGH_LEVEL = 800.freeze
  DEFAULT_VERY_HIGH_LEVEL = 1200.freeze
  DEFAULT_START_TIME = "12:00".freeze
  DEFAULT_STOP_TIME = "19:00".freeze
  DEFAULT_PING_TIMEOUT = 60.freeze

  def self.get
    new YAML.load_file(config_file)
  end

  def self.set
    FileUtils.mkdir_p(config_dir) unless File.directory?(config_dir)

    data = {}.tap do |h|
      print "Monitor location (required): "
      h["location"] = STDIN.gets.chomp
      print "Monitor user (required): "
      h["user"] = STDIN.gets.chomp
      print "Hipchat API token (required): "
      h["api_token"] = STDIN.gets.chomp
      print "Hipchat room name (required): "
      h["room"] = STDIN.gets.chomp
      print "Timeout (default: #{DEFAULT_TIMEOUT} mins): "
      h["timeout"] = STDIN.gets.chomp.presence || DEFAULT_TIMEOUT
      print "Cooldown (default: #{DEFAULT_COOLDOWN} mins): "
      h["cooldown"] = STDIN.gets.chomp.presence || DEFAULT_COOLDOWN
      print "Ping timeout (default: #{DEFAULT_PING_TIMEOUT} mins): "
      h["ping_timeout"] = STDIN.gets.chomp.presence || DEFAULT_PING_TIMEOUT
      print "High CO₂ level (default: #{DEFAULT_HIGH_LEVEL}): "
      h["high_level"] = STDIN.gets.chomp.presence || DEFAULT_HIGH_LEVEL
      print "Very High CO₂ level (default: #{DEFAULT_VERY_HIGH_LEVEL}): "
      h["very_high_level"] = STDIN.gets.chomp.presence || DEFAULT_VERY_HIGH_LEVEL
      print "Start time (default: #{DEFAULT_START_TIME}): "
      h["start_time"] = STDIN.gets.chomp.presence || DEFAULT_START_TIME
      print "Stop time (default: #{DEFAULT_STOP_TIME}): "
      h["stop_time"] = STDIN.gets.chomp.presence || DEFAULT_STOP_TIME
      print "Mention (optional): "
      h["mention"] = STDIN.gets.chomp
    end

    File.open(config_file, "w") do |f|
      YAML.dump(data, f)
    end
  end

  def self.config_dir
    File.join(ENV['HOME'], CONFIG_DIR)
  end

  def self.config_file
    File.join(config_dir, CONFIG_FILE_NAME)
  end

  def self.output_path
    File.join(config_dir, OUTPUT_FILE_NAME)
  end

  def self.error_path
    File.join(config_dir, ERROR_FILE_NAME)
  end
end
