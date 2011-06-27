require 'rubygems'
require '../lib/opml_speed_reader'
require 'yaml'


def fetch(io)
  reader = XML::Reader.io(io)
  stack = []
  title = OpmlSpeedReader.parse_header(reader, stack)

  stack.pop

  feeds = []
  OpmlSpeedReader.parse_body(reader, stack) do |feed|
    feeds << feed
  end

  return {:title => title, :feeds => feeds}
end


puts fetch(STDIN).to_yaml
