# -*- ruby -*-
task :default => :test

desc "Run tests"
task :test do
  FileList["test/data/*.strace"].each do |strace|
    base = strace.chomp ".strace"
    pcap_expected = base + ".pcap"
    pcap_actual = base + "-test.pcap"

    sh "bin/dbus-dump #{strace} #{pcap_actual} && cmp #{pcap_expected} #{pcap_actual}"
  end
  puts "Test Passed"
end

desc "Build the documentation"
task :doc => "README.html"

file "README.html" => "README.markdown" do |t|
  sh "markdown #{t.prerequisites[0]} > #{t.name}"
end
