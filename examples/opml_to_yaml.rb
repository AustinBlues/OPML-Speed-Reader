require 'rubygems'
require '../lib/opml_speed_reader'
require 'yaml'

begin
  reader = REXML::Parsers::PullParser.new(STDIN)
  puts OpmlSpeedReader.parse(reader).to_yaml
#rescue OpmlSpeedReader::NotOPML
#  STDERR.puts "Not OPML"
#  exit 1
end
