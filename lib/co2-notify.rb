require "thor"
require "co2mon"
require "hipchat"
require "plist"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/module/delegation"

class Co2Notify < Thor
  PLIST_NAME = "arkadiybutermanov.co2-notify".freeze

  desc "go", "start notifier"
  def go
    Notifier.start
  end

  desc "start", "start notifier in background"
  def start
    system "launchctl load #{plist_path}"
  end

  desc "stop", "stop background notifier"
  def stop
    system "launchctl unload #{plist_path}"
  end

  desc "init", "setup config"
  def init
    Config.set
  end

  desc "autoload", "setup OSX plist"
  def autoload(path)
    data = {
      "KeepAlive" => true,
      "Label" => PLIST_NAME,
      "ProgramArguments" => [
        path,
        "go"
      ],
      "RunAtLoad" => true
    }

    File.open(plist_path, "w") do |f|
      f.write Plist::Emit.dump(data)
    end
  end

  private

  def plist_path
    File.expand_path("Library/LaunchAgents/#{PLIST_NAME}.plist", ENV["HOME"])
  end
end

require_relative "co2-notify/config"
require_relative "co2-notify/status"
require_relative "co2-notify/hipchat_client"
require_relative "co2-notify/notifier"
