require 'rubygems'
require '../lib/opml_speed_reader'
require 'yaml'


puts OpmlSpeedReader.parse(STDIN).to_yaml
