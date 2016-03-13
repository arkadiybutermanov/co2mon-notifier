require "thor"
require "co2mon"
require "hipchat"
require "plist"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/module/delegation"

class Co2Notify < Thor
  PLIST_NAME = "arkadiybutermanov.co2-notify".freeze

  desc "start", "start notifier"
  def start
    Notifier.start
  end

  desc "init", "setup config"
  def init
    Config.set
  end

  desc "autoload", "setup OSX plist"
  def autoload(path)
    target_path = File.expand_path("Library/LaunchAgents/#{PLIST_NAME}.plist", ENV["HOME"])
    data = {
      "KeepAlive" => true,
      "Label" => PLIST_NAME,
      "ProgramArguments" => [
        path,
        "start"
      ],
      "RunAtLoad" => true
    }

    File.open(target_path, "w") do |f|
      f.write Plist::Emit.dump(data)
    end
  end
end

require_relative "co2-notify/config"
require_relative "co2-notify/status"
require_relative "co2-notify/hipchat_client"
require_relative "co2-notify/notifier"
