require 'xml'
require 'opml_speed_reader/version'


module OpmlSpeedReader
  # Parse OPML, reading XML from +reader+, returning hash with all RSS
  # feed relevant data.
  def self.parse(reader)
    title = nil
    feeds = []

    tag = nil
    feed = {}

    while reader.read
      case reader.node_type
      when XML::Reader::TYPE_ELEMENT
	case tag = reader.name
	when 'outline'
	  feed = {:title => reader['text'].strip}
	  feed[:url] = reader['xmlUrl'].strip if reader['xmlUrl']
	  if reader.empty_element? && feed[:url]
	    feeds << feed
	    feed = {}
	  end
	end
      when XML::Reader::TYPE_TEXT, XML::Reader::TYPE_CDATA
	case tag
	when 'title'
	  title = reader.value.strip
	end
      when XML::Reader::TYPE_END_ELEMENT
	case tag
	when 'outline'
	  if feed[:url]
	    feeds << feed
	    feed = {}
	  end
	end
      end
    end

    feeds.unshift(title)
  end
end
