require 'formula'

class Sickbeard < Formula
  url 'https://github.com/midgetspy/Sick-Beard/tarball/build-489'
  homepage 'http://www.sickbeard.com/'
  md5 'fee7c987f12dc48f0d7c057c9f61c180'

  head 'https://github.com/midgetspy/Sick-Beard.git'

  depends_on 'Cheetah' => :python

  def install
    prefix.install Dir['*']
    bin.mkpath
    (bin+"sickbeard").write(startup_script)
    plist_path.write(startup_plist)
    plist_path.chmod 0644
  end

  def startup_plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
           <string>#{HOMEBREW_PREFIX}/bin/sickbeard</string>
           <string>-q</string>
           <string>--nolaunch</string>
           <string>-p</string>
           <string>8081</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>UserName</key>
      <string>#{`whoami`.chomp}</string>
    </dict>
    </plist>
    EOS
  end

  def startup_script; <<-EOS.undent
    #!/usr/bin/env ruby

    me = begin
      File.expand_path(
        File.join(
          File.dirname(__FILE__),
          File.readlink(__FILE__)
        )
      )
    rescue
      __FILE__
    end

    path = File.join(File.dirname(me), '..', 'SickBeard.py')
    args = ["--pidfile=#{var}/run/sickbeard.pid", "--datadir=#{etc}/sickbeard"]

    exec("python", path, *(args + ARGV))
    EOS
  end

  def caveats; <<-EOS.undent
    SickBeard will start up and launch http://localhost:8081/ when you run:

        sickbeard

    To launch automatically on startup, copy and paste the following into a terminal:

        mkdir -p ~/Library/LaunchAgents
        (launchctl unload -w ~/Library/LaunchAgents/#{plist_path.basename} 2>/dev/null || true)
        ln -sf #{plist_path} ~/Library/LaunchAgents/#{plist_path.basename}
        launchctl load -w ~/Library/LaunchAgents/#{plist_path.basename}

    You may want to edit:
      #{plist_path}
    to change the port (default: 8081) or user (default: #{`whoami`.chomp}).
    EOS
  end
end
