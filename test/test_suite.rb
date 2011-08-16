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
      assert (opml == expected)
    end
  end


  # Test exception thrown for non-OPML file (it's an HTML file, a
  # common user mistake.
  def test_not_opml
    reader = XML::Reader.io(open('./test/opml/not_opml.html'))
    assert_raise OpmlSpeedReader::NotOPML do
      OpmlSpeedReader.parse(reader)
    end
  end


  # All OPML file in test fixtures with YAML files are real OPML.
  def test_opml_detection
    Dir['./test/opml/*.yml'].each do |filename|
      reader = XML::Reader.io(open(filename.gsub(/\.yml\Z/, '.xml')))
      assert (OpmlSpeedReader.opml?(reader))
    end
  end


  # Test exception thrown for non-OPML file (it's an HTML file, a
  # common user mistake.
  def test_not_opml_detection
    reader = XML::Reader.io(open('./test/opml/not_opml.html'))
    assert (!OpmlSpeedReader.opml?(reader))
  end
end
