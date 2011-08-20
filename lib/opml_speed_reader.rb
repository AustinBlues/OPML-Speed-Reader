require 'xml'
require 'opml_speed_reader/version'


module OpmlSpeedReader
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
	stack.pop if reader.empty_element?
      when XML::Reader::TYPE_TEXT, XML::Reader::TYPE_CDATA
	path = stack.join('/')
	ignore = false
	case path
	when 'opml/head/title'
	  title = reader.value.strip
	end
      when XML::Reader::TYPE_END_ELEMENT
	stack.pop
      end
      status = reader.read
    end
    title
  end


  def self.parse_body(reader, stack)
    feed = {}		# force scope
    begin	# post test loop
      case reader.node_type
      when XML::Reader::TYPE_ELEMENT
	stack << reader.name
	path = stack.join('/')
	ignore = false
	case path
	when %r|opml/body(/outline)+|
	  feed['title'] = reader['text'].strip
	  feed['feed_url'] = reader['xmlUrl'].strip if reader['xmlUrl']
	  if reader.empty_element? && feed['feed_url']
	    yield feed
	    feed = {}
	  end
	else
	  ignore = true  
	end
	stack.pop if reader.empty_element?
      when XML::Reader::TYPE_END_ELEMENT
	path = stack.join('/')
	case path
	when %r|opml/body(/outline)+|
	    if feed['feed_url']
	      yield feed
	      feed = {}
	    end
	end
	stack.pop
      end
    end while reader.read
  end

  # Parse OPML, reading XML from +io+, returning hash with all RSS
  # feed relevant data.
  def self.parse(reader)
    stack = []
    title = OpmlSpeedReader.parse_header(reader, stack)

    stack.pop

    feeds = [title]
    OpmlSpeedReader.parse_body(reader, stack) do |feed|
      feeds << feed
    end

    feeds
  end
end
