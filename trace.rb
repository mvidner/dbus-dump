#! /usr/bin/env ruby
# tap into dbus-daemon via strace and decode the messages.
# todo: just dump them, let another app read it
# (like a fake dbus daemon that has no denial rules. dbus-daemon-proxy?)

require "dbus"
require "pp"

# strace -p `pgrep -f 'dbus-daemon --system'` -s 3000 -xx -o /root/tracer
def parse(filename)
  File.open(filename) do |f|
    while not f.eof?
      l = f.readline.chomp
      case l
      when /^(writev?|read)\((\d*),/
        rw = $1.upcase
        conn = $2
        s = ""
        while l =~ /[^\"]*\"([^\"]*)\"(.*)/
          ss = $1
          l = $2
          dehex = [ss.gsub '\x', ''].pack 'H*'
          s += dehex
        end
        if s =~ /\A[lB]..\x01/  # FIXME misses a Hello tacked onto the BEGIN
          puts rw, conn, s
          m, size = DBus::Message.new.unmarshall_buffer(s)
          pp m
        end
      end
    end
  end
end

parse ARGV[0]
