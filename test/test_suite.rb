#! /usr/bin/ruby
#
require 'test/unit'
require 'xml'
require 'opml_speed_reader'


class TestOpml < Test::Unit::TestCase
  def setup
    # Disable noisy error reporting by libxml2 library on STDOUT
    XML::Error.set_handler(&XML::Error::QUIET_HANDLER)
  end


  # Compare output for OPML files against expected (YAML test fixtures)
  def test_parsing
    Dir['./test/opml/*.yml'].each do |filename|
      expected = YAML::load( File.open( filename ) )
      reader = XML::Reader.io(open(filename.gsub(/\.yml\Z/, '.xml')))
      opml = OpmlSpeedReader.parse(reader)
#      STDERR.puts "EXPECTED: #{expected.to_yaml}."
#      STDERR.puts "OPML: #{opml.to_yaml}."
      assert (opml == expected)
    end
  end
end
