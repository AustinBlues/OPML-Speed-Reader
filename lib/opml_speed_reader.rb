require 'xml'
require 'opml_speed_reader/version'


module OpmlSpeedReader
  class NotOPML < StandardError; end

#  TRACE = [:all_elements]
  TRACE = []

  # Trace parse - for use by developers; expects block with debug string to print
  # <tt>element</tt>: type of element
  def OpmlSpeedReader.trace(element)
    if OpmlSpeedReader::TRACE.include?(:all_elements) ||
	OpmlSpeedReader::TRACE.include?(element)
      puts yield
    end
  end


  # Parse header of OPML file
  # <tt>reader</tt> - +XML::Reader+ object to read from
  # <tt>stack</tt> - parse stack, initially empty
  def OpmlSpeedReader.parse_header(reader, stack)
    title = nil

    begin
      status = reader.read
    rescue LibXML::XML::Error
      raise NotOPML
    end while status && reader.node_type == XML::Reader::TYPE_COMMENT

    raise NotOPML unless !status || (reader.node_type == XML::Reader::TYPE_ELEMENT && reader.name == 'opml')

    while status
      case reader.node_type
      when XML::Reader::TYPE_ELEMENT
	stack << reader.name
	path = stack.join('/')
	ignore = false
	case path
	when 'opml/body'
	  break		# end of header
	else
	  ignore = true
	end
	if (OpmlSpeedReader::TRACE.include?(:essential_elements) && !ignore) ||
	    OpmlSpeedReader::TRACE.include?(:all_elements)
	  puts "HEADER(#{path})"
	end
	stack.pop if reader.empty_element?
      when XML::Reader::TYPE_TEXT, XML::Reader::TYPE_CDATA
	path = stack.join('/')
	ignore = false
	case path
	when 'opml/head/title'
	  title = reader.value.strip
	end
	if (OpmlSpeedReader::TRACE.include?(:essential_values) && !ignore) ||
	    OpmlSpeedReader::TRACE.include?(:all_values)
	  puts "HEADER(#{path}): #{reader.value}"
	end
      when XML::Reader::TYPE_END_ELEMENT
	stack.pop
      end
      status = reader.read
    end
    title
  end



  # Parse OPML file for RSS/Atom feeds
  # <tt>reader</tt>: +XML::Reader+ object to read from
  # <tt>stack</tt>: parse stack from parse_header()
  def self.parse_body(reader, stack)
    libxml = {}		# force scope
    begin	# post test loop
      case reader.node_type
      when XML::Reader::TYPE_ELEMENT
	stack << reader.name
	path = stack.join('/')
	case path
	when %r|opml/body(/outline)+|
	  libxml['title'] = (!!reader['title']) ? reader['title'].strip : reader['text'].strip
	  libxml['feed_url'] = reader['xmlUrl'].strip if reader['xmlUrl']
	  OpmlSpeedReader.trace(:essential_elements) do
	    "BEGIN(#{path}): '#{libxml['title']}' '#{libxml['feed_url']}' #{stack.size-3}."
	  end
	  yield(libxml.dup, stack.size - 3) unless libxml.empty?
	end
	stack.pop if reader.empty_element?
      when XML::Reader::TYPE_END_ELEMENT
	path = stack.join('/')
	case path
	when %r|opml/body(/outline)+|
	  libxml = {}
	end
	stack.pop
      end
    end while reader.read
  end


  # Is source in reader in OPML format?
  def self.opml?(reader)
    parser_stack = []
    title = OpmlSpeedReader.parse_header(reader, parser_stack)
  rescue OpmlSpeedReader::NotOPML
    false
  else
    true
  end


  # Parse OPML, reading XML from +io+, returning hash with all RSS
  # feed relevant data.
  def self.parse(reader)
    parser_stack = []
    title = OpmlSpeedReader.parse_header(reader, parser_stack)

    parser_stack.pop

    feed_stack = [[title]]
    OpmlSpeedReader.parse_body(reader, parser_stack) do |feed, depth|
      if feed.size > 1
	raise if ((depth+1) <=> (feed_stack.size)) == -1
	feed_stack[-1] << feed
      else
	case depth+1 <=> feed_stack.size
	when +1:
	  raise
	when 0:
	  feed_stack << [feed['title']]
	when -1:
	  tmp = feed_stack.pop
	  feed_stack[-1] << tmp
	  feed_stack << [feed['title']]
	else
	  raise
	end
      end
    end

    # Nested feeds (e.g. Google categories) need final flattening.
    while feed_stack.size > 1
      tmp = feed_stack.pop
      feed_stack[-1] << tmp
    end

    feed_stack[0]
  end
end
