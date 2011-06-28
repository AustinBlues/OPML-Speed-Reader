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
#      puts "EXPECTD: #{expected.inspect}."
      io = open(filename.gsub(/\.yml\Z/, '.xml'))
      opml = OpmlSpeedReader.parse(io)
#      puts "ACTUAL:  #{opml.inspect}."
#      puts "ACTUAL: #{opml[:feeds].map{|a| "'#{a.title}'"}.join(", ")}."
#      puts "DETAILS: #{opml[:details].inspect}."
#      expected[:items].each do |item|
      expected[:feeds].each do |feed|
#	puts "FEED: |#{feed.inspect}|"
	feed['title'].gsub!(/&#x([0-9a-f]+);/i){ [$1.hex].pack("U*")}
	a = opml[:feeds].detect{|i| feed['title'] == i['title']}
	if a.nil?
	  puts "MISSING EXPECTED: '#{feed['title']}'."
	else
	  assert feed['title'] == a['title'], "FEED TITLE: '#{a['title']}' vs. '#{feed['title']}'."
	  assert a['url'] == feed['url'], "FEED URL: '#{a['url']}' vs. '#{feed['url']}'."

	  opml[:feeds].delete(a)
	end
      end
#      puts "OPML: |#{opml[:feeds].inspect}|"
      assert(opml[:feeds].empty?,
	     "#{opml[:feeds].length} channels expected in #{filename.gsub(%r{.*/}, '')} not found.")
    end
  end
end
