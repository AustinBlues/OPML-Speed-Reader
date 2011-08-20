#! /usr/bin/ruby
#
require 'test/unit'
require 'xml'
require 'opml_speed_reader'


class TestOpml < Test::Unit::TestCase
  def test_parsing
    Dir['./test/opml/*.yml'].each do |filename|
#      puts "FILE: #{filename}."
      expected = YAML::load( File.open( filename ) )
      io = open(filename.gsub(/\.yml\Z/, '.xml'))
      reader = XML::Reader.io(io)
      opml = OpmlSpeedReader.parse(reader)
#      puts "EXPECTED: #{expected.to_yaml}."
#      puts "ACTUAL:  #{opml.to_yaml}."
      assert opml == expected
    end
  end
end
