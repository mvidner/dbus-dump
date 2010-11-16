dbus-dump
=========

dbus-dump is a tool to capture [D-Bus][1] messages
in a [libpcap capture file][2].

[1]: http://www.freedesktop.org/wiki/Software/dbus
[2]: http://wiki.wireshark.org/Development/LibpcapFileFormat

It takes an idea from [dbus-scrape][3], which processes a strace output of
dbus-monitor, and takes it further by stracing dbus-daemon, thus not
relying on any eavesdropping (mis)configuration.

[3]: http://git.collabora.co.uk/?p=user/daf/dbus-scrape;a=summary

The intended purpose is to establish the libpcap capture format as a
base for debugging tools like

- dbus-monitor
- [DBusMessageBox](http://alban.apinc.org/blog/dbusmessagesboxpy/)
- [Bustle](http://www.willthompson.co.uk/bustle/)
- [dbus-spy](http://mvidner.blogspot.com/2008/06/d-bus-spy.html)

Thanks to Will Thompson for mentioning the pcap idea.

Usage
-----

    $ sudo strace -p `pgrep -f 'dbus-daemon --system'` \
        -s 3000 -ttt -xx -o foo.strace
    $ ./dbus-dump foo.strace foo.pcap
    $ ./dbus-pcap-parse foo.pcap
    Tue Nov 16 12:56:47 +0100 2010 #<DBus::Message:0xb741f340
     @body_length=0,
     @destination="fi.epitest.hostap.WPASupplicant",
     @error_name=nil,
     @flags=0,
     @interface="fi.epitest.hostap.WPASupplicant.Interface",
     @member="scan",
     @message_type=1,
     @params=[],
     @path="/fi/epitest/hostap/WPASupplicant/Interfaces/180",
     @protocol=1,
     @reply_serial=nil,
     @sender=":1.7132",
     @serial=88639,
     @signature="">
    Tue Nov 16 12:56:47 +0100 2010 #<DBus::Message:0xb741b060
     @body_length=4,
     @destination=":1.7132",
    [...]>

Dependencies
------------

It is written in Ruby. The pcap format is handled by a small bundled module.
dbus-dump has no other dependencies. dbus-pcap-parse uses
[ruby-dbus](https://github.com/mvidner/ruby-dbus).

Bugs
----

This is an early proof-of-concept release, serving to introduce
the libpcap format.

The main problem of dbus-dump is duplicating the messages, seeing them
both when the daemon receives them and when it sends them (multiple
times, for the signals).

The other tools haven't caught up yet:

    $ /usr/sbin/tcpdump -r foo.pcap
    reading from file foo.pcap, link-type 231
    tcpdump: unknown data link type 231

Contact
-------

Written by Martin Vidner, `martin at vidner dot net`.
