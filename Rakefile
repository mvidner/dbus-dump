# -*- ruby -*-
task :default => :test

desc "Run tests"
task :test do
  sh "./dbus-dump data/session.strace data/session-test.pcap && cmp data/session.pcap data/session-test.pcap || echo Test Failed"
  sh "./dbus-dump data/session-1.4.strace data/session-1.4-test.pcap && cmp data/session-1.4.pcap data/session-1.4-test.pcap || echo Test Failed"
  puts "Test Passed"
end

desc "Build the documentation"
task :doc => "README.html"

file "README.html" => "README.markdown" do |t|
  sh "markdown #{t.prerequisites[0]} > #{t.name}"
end