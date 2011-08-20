require 'rubygems'
require '../lib/opml_speed_reader'
require 'yaml'


reader = XML::Reader.io(STDIN)
puts OpmlSpeedReader.parse(reader).to_yaml
