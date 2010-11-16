#! /usr/bin/env ruby

require "stringio"
require "dbus"
require "pp"

def u32(io)
  io.read(4).unpack("V")[0]
end

def i32(io)
  io.read(4).unpack("l")[0]
end

def u16(io)
  io.read(2).unpack("v")[0]
end

class PcapGlobalHeader
  def initialize(io)
    @magic_number = u32(io)
    @version_major = u16(io)
    @version_minor = u16(io)
    @thiszone = i32(io)
    @sigfigs = u32(io)
    @snaplen = u32(io)
    @network = u32(io)          # 1 == Ethernet
    fail unless @magic_number == 0xa1b2c3d4 and @version_major == 2 and @version_minor == 4 and @network == 1
  end
end

class PcapPacket
  attr :timestamp
  attr :original_length
  attr :data
  def initialize(io)
    sec = u32(io)
    usec = u32(io)
    @timestamp = Time.at(sec, usec)
    length = u32(io)
    @original_length = u32(io)
    @data = io.read(length)
  end
end

class EthernetHeader
  def initialize(io)
    @destination = io.read(6)
    @source = io.read(6)
    @type = io.read(2).unpack("n")[0]
    fail unless @type == 0x0800
  end
end

class IpHeader
  def initialize(io)
    header = io.read(20)
    version_length = header[0]
    version = version_length >> 4
    length = (version_length & 0x0f) * 4
    fail unless version == 4 and length == 20
    protocol = header[9]
    fail unless protocol == 6   # TCP
  end
end

class TcpHeader
  def initialize(io)
    header = io.read(20)
    data_offset = (header[12] >> 4) * 4
#    print data_offset
    optional_header = io.read(data_offset - 20)
  end
end

io = ARGF
header = PcapGlobalHeader.new(io)
p header
while not io.eof? do
  packet = PcapPacket.new(io)
  sio = StringIO.new(packet.data)
  eh = EthernetHeader.new(sio)
  ih = IpHeader.new(sio)
  th = TcpHeader.new(sio)
  print "."
  payload = sio.read
  next if payload.empty?
  pp payload
  puts [payload].pack "H*"
  msg, size = DBus::Message.new.unmarshall_buffer(payload)
  pp msg
end
puts "!"
