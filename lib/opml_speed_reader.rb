require 'xml'
require 'opml_speed_reader/version'


module OpmlSpeedReader
  # Parse OPML, reading XML from +reader+, returning hash with all RSS
  # feed relevant data.
  def self.parse(reader)
    title = nil
    feed_stack = [[]]
    tag_stack = []

    tag = nil	# force scope
    feed = {}
    
    while reader.read
      case reader.node_type
      when XML::Reader::TYPE_ELEMENT
	tag = reader.name
	tag_stack.push(tag)
	case tag_stack.join('>')
	when /opml>body(>outline)+/
	  feed = {:title => reader['text'].strip}
	  feed[:url] = reader['xmlUrl'].strip if reader['xmlUrl']
	  if feed[:url].nil?	# Category/folder start?
	    feed_stack.push([feed[:title]])
	  else
	    feed_stack[-1] << feed
	    feed = {}
	  end
	  if reader.empty_element?
	    tag_stack.pop
	  end
	end
      when XML::Reader::TYPE_TEXT, XML::Reader::TYPE_CDATA
	case tag_stack.join('>')
	when 'opml>head>title'
	  title = reader.value.strip
	  feed_stack[0].unshift(title)
	end
      when XML::Reader::TYPE_END_ELEMENT
	case tag_stack.join('>')
	when /opml>body(>outline)+/
	  tmp = feed_stack.pop
	  feed_stack[-1] << tmp
	end
	tag_stack.pop
      end
    end

    # flatten feed_stack
    while feed_stack.size > 1
      tmp = feed_stack.pop
      feed_stack[-1] << tmp
    end

    feed_stack[0]
  end
end
