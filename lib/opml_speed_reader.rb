#require 'xml'
require 'rexml/parsers/pullparser'
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

    while reader.has_next?
      event = reader.pull
      case event.event_type
      when :start_element
	tag = event[0]
	tag_stack.push(tag)
	case tag_stack.join('>')
	when /^opml>body(>outline)+$/
	  feed = {:title => event[1]['text'].strip}
	  feed[:url] = event[1]['xmlUrl'].strip if event[1]['xmlUrl']
	  if feed[:url].nil?	# Category/folder start?
	    feed_stack.push([feed[:title]])
	  else
	    feed_stack[-1] << feed
	    feed = {}
	  end
	end
      when :text, :cdata
	case tag_stack.join('>')
	when 'opml>head>title'
	  feed_stack[0].unshift(event[0])
	end
      when :end_element
	case tag_stack.join('>')
	when 'opml>body>outline'
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
