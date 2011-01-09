# -*- ruby -*-
task :default => :test

begin
  require "jeweler"
  require "jeweler/rubygems_tasks"
  Jeweler::Tasks.new do |gem|
    # gem is a Gem::Specification, http://docs.rubygems.org/read/chapter/20
    gem.name = "dbus-dump"
    gem.summary = "a tool to capture D-Bus messages in a libpcap capture file"
    gem.description = %Q{It takes an idea from dbus-scrape,
which processes a strace output of
dbus-monitor, and takes it further by stracing dbus-daemon, thus not
relying on any eavesdropping (mis)configuration.}
    gem.email = "martin@vidner.net"
    gem.homepage = "http://github.com/mvidner/dbus-dump"
    gem.authors = ["Martin Vidner"]
    gem.platform = Gem::Platform::RUBY

    gem.files = FileList["bin/dbus-*", "lib/**/*.rb",
                         "test/data/*.{strace,pcap}"]

    gem.add_dependency "ruby-dbus"
  end
  Jeweler::RubygemsDotOrgTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

desc "Run tests"
task :test do
  FileList["test/data/*.strace"].each do |strace|
    base = strace.chomp ".strace"
    pcap_expected = base + ".pcap"
    pcap_actual = base + "-test.pcap"

    sh "bin/dbus-dump #{strace} #{pcap_actual} && cmp #{pcap_expected} #{pcap_actual}"
    rm pcap_actual
  end
  puts "Test Passed"
end

desc "Build the documentation"
task :doc => "README.html"

file "README.html" => "README.markdown" do |t|
  sh "markdown #{t.prerequisites[0]} > #{t.name}"
end

