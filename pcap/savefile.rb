#! /usr/bin/env ruby
# Author:  Martin Vidner, https://github.com/mvidner
# License: http://creativecommons.org/licenses/MIT/

# A small library to use the libpcap file format in dbus-dump
# http://wiki.wireshark.org/Development/LibpcapFileFormat
module Pcap
  module Savefile
    # helper
    module EasyIO
      # write in little endian order
      def wu32(io, u32)
        s = [u32].pack("V")
        io.write(s)
      end

      def wi32(io, i32)
        s = [i32].pack("l")
        io.write(s)
      end

      def wu16(io, u16)
        s = [u16].pack("v")
        io.write(s)
      end

      def u32(io)
        io.read(4).unpack("V")[0]
      end

      def i32(io)
        io.read(4).unpack("l")[0]
      end

      def u16(io)
        io.read(2).unpack("v")[0]
      end
    end

    class GlobalHeader
      include EasyIO

      MAGIC_NUMBER = 0xa1b2c3d4
      VERSION_MAJOR = 2
      VERSION_MINOR = 4
      THIS_ZONE = 0             # we write times in UTC

      # significant figures in time stamps
      attr_accessor :sigfigs
      # snapshot length, packets longer than this are truncated
      attr_accessor :snaplen
      # data link layer type
      attr_accessor :network
      def initialize(network)
        @sigfigs = 0
        @snaplen = 65535
        @network = network
      end

      # io is a stream open for writing
      # TODO good API, name, usage
      def write(io)
        wu32(io, MAGIC_NUMBER)
        wu16(io, VERSION_MAJOR)
        wu16(io, VERSION_MINOR)
        wi32(io, THIS_ZONE)
        wu32(io, sigfigs)
        wu32(io, snaplen)
        wu32(io, network)
      end

      class << self
        include EasyIO

        def from_io(io)
          magic_number = u32(io)
          raise "Bad magic: #{magic_number}" unless magic_number == MAGIC_NUMBER
          version_major = u16(io)
          version_minor = u16(io)
          raise "Bad version #{version_major}.#{version_minor}" unless version_major == VERSION_MAJOR and version_minor == VERSION_MINOR
          thiszone = i32(io)     # TODO use it
          sigfigs = u32(io)
          snaplen = u32(io)
          network = u32(io)          # 1 == Ethernet
          header = self.new(network)
          header.sigfigs = sigfigs
          header.snaplen = snaplen
          header
        end
      end
    end # class GlobalHeader

    class Packet
      include EasyIO

      # Time
      attr :time
      # String
      attr :data

      # original length of data
      def orig_len
        @orig_len || incl_len
      end
      attr_writer :orig_len

      # included length
      def incl_len
        data.length
      end

      def initialize(data, time = nil, orig_len = nil)
        @data = data
        @time = time || Time.now
        @orig_len = orig_len
      end

      def write(io)
        u = time.getutc
        wu32(io, u.tv_sec)
        wu32(io, u.tv_usec)
        wu32(io, incl_len)
        wu32(io, orig_len)
        io.write(data)
      end

      class << self
        include EasyIO

        def from_io(io)
          sec = u32(io)
          usec = u32(io)
          timestamp = Time.at(sec, usec)
          length = u32(io)
          original_length = u32(io)
          data = io.read(length)
          packet = self.new(data, timestamp, original_length)
          packet
        end
      end
    end # class Packet
  end # module Savefile
end # module Pcap
