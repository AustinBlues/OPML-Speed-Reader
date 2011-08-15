require 'rubygems'
require '../lib/opml_speed_reader'
require 'yaml'


# Disable noisy error reporting by libxml2 library on STDOUT
XML::Error.set_handler(&XML::Error::QUIET_HANDLER)

begin
  reader = XML::Reader.io(STDIN)
  puts OpmlSpeedReader.parse(reader).to_yaml
rescue OpmlSpeedReader::NotOPML
  STDERR.puts "Not OPML"
  exit 1
end
