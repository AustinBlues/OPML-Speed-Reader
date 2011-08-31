require 'rubygems'
require '../lib/opml_speed_reader'
require 'yaml'


# Disable noisy error reporting by libxml2 library on STDOUT
XML::Error.set_handler(&XML::Error::QUIET_HANDLER)

reader = XML::Reader.io(STDIN)
puts OpmlSpeedReader.parse(reader).to_yaml
