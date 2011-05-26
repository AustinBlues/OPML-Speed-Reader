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
      opml = fetch(reader)
#      puts "ACTUAL: #{opml[:feeds].inspect}."
#      puts "ACTUAL: #{opml[:feeds].map{|a| "'#{a.title}'"}.join(", ")}."
#      puts "DETAILS: #{opml[:details].inspect}."
      expected[:items].each do |item|
#	puts "ITEM: |#{item.inspect}|"
	item[:title].gsub!(/&#x([0-9a-f]+);/i){ [$1.hex].pack("U*")}
	a = opml[:feeds].detect{|i| item[:title] == i['title']}
#	a = opml.detect{|i| item[:title] == i.title}
	if a.nil?
	  puts "MISSING EXPECTED: '#{item[:title]}'."
	else
	  assert item[:title] == a['title'], "ITEM TITLE: '#{a['title']}' vs. '#{item[:title]}'."
	  assert a['url'] == item[:url], "ITEM URL: '#{a['url']}' vs. '#{item[:url]}'."

	  opml[:feeds].delete(a)
	end
      end
#      puts "OPML: |#{opml[:feeds].inspect}|"
      assert(opml[:feeds].empty?,
	     "#{opml[:feeds].length} channels expected in #{filename.gsub(%r{.*/}, '')} not found.")
    end
  end


  def fetch(reader)
    title = ''
#    details = []
    feeds = []
    stack = []

    begin
      title = OpmlSpeedReader.parse_header(reader, stack)

      stack.pop

      OpmlSpeedReader.parse_body(reader, stack) do |libxml|
	feeds << libxml
      end

      {:title => title, :feeds => feeds}
    end
  end
end
