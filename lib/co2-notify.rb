require "thor"
require "co2mon"
require "hipchat"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/module/delegation"

class Co2Notify < Thor
  desc "start", "start notifier"
  def start
    Notifier.start
  end

  desc "init", "setup config"
  def init
    Config.set
  end
end

require_relative "co2-notify/config"
require_relative "co2-notify/status"
require_relative "co2-notify/hipchat_client"
require_relative "co2-notify/notifier"
