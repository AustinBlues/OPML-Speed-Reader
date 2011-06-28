#require 'libxml-ruby'
require 'xml'
require 'opml_speed_reader/version'


module OpmlSpeedReader
  #TRACE = [:all_elements]
  TRACE = []

  def OpmlSpeedReader.parse_header(reader, stack)
    title = nil

    begin
      status = reader.read
    rescue
      return title
    end

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


  def self.parse_body(reader, stack)
    libxml = {}		# force scope
    begin	# post test loop
      case reader.node_type
      when XML::Reader::TYPE_ELEMENT
	stack << reader.name
	path = stack.join('/')
	ignore = false
	case path
	when %r|opml/body(/outline)+|
	  libxml['title'] = reader['text'].strip
	  libxml['url'] = reader['xmlUrl'].strip if reader['xmlUrl']
	  if reader.empty_element? && libxml['url']
	    yield libxml
	    libxml = {}
	  end
	else
	  ignore = true  
	end
	if (OpmlSpeedReader::TRACE.include?(:essential_elements) && !ignore) ||
	    OpmlSpeedReader::TRACE.include?(:all_elements)
	  puts "BEGIN(#{path}): '#{libxml['title']}' '#{libxml['url']}'."
	end
	stack.pop if reader.empty_element?
      when XML::Reader::TYPE_END_ELEMENT
	path = stack.join('/')
	case path
	when %r|opml/body(/outline)+|
	    if libxml['url']
	      yield libxml
	      libxml = {}
	    end
	end
	stack.pop
      end
    end while reader.read
  end

  # Parse OPML, reading XML from +io+, returning hash with all RSS
  # feed relevant data.
  def self.parse(io)
    reader = XML::Reader.io(io)
    stack = []
    title = OpmlSpeedReader.parse_header(reader, stack)

    stack.pop

    feeds = []
    OpmlSpeedReader.parse_body(reader, stack) do |feed|
      feeds << feed
    end

    {:title => title, :feeds => feeds}
  end
end
