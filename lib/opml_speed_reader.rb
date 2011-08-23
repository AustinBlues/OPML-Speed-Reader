require 'xml'
require 'opml_speed_reader/version'


module OpmlSpeedReader
  class NotOPML < StandardError; end

  class NamedArray
    attr_reader :name, :array

    def initialize(name)
      @name = name
      @array = []
    end

    def [](index)
      @array[index]
    end

    def <<(element)
      @array << element
    end

    def pop
      @array.pop
    end

    def size
      @array.size
    end

    def ==(other)
      (self.name == other.name) && (self.array == other.array)
    end
  end

  class Feed
    attr_reader :title, :url

    def initialize(title, url)
      @title, @url = title, url
    end

    def ==(other)
      (self.title == other.title) && (self.url == other.url)
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
      raise NotOPML, 'Not XML'
    else
      raise NotOPML, 'Empty file' if !status	# EOF
    end while reader.node_type == XML::Reader::TYPE_COMMENT

    raise NotOPML, reader.name if reader.node_type == XML::Reader::TYPE_ELEMENT && reader.name != 'opml'

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



  # Parse OPML file for RSS/Atom feeds
  # <tt>reader</tt>: +XML::Reader+ object to read from
  # <tt>stack</tt>: parse stack from parse_header()
  def self.parse_body(reader, stack)
    feed = {}		# force scope
    begin	# post test loop
      case reader.node_type
      when XML::Reader::TYPE_ELEMENT
	stack << reader.name
	path = stack.join('/')
	case path
	when %r|opml/body(/outline)+|
	  feed[:title] = (!!reader['title']) ? reader['title'].strip : reader['text'].strip
	  feed[:url] = reader['xmlUrl'].strip if reader['xmlUrl']
	  yield(feed.dup, stack.size - 3) unless feed.empty?
	end
	stack.pop if reader.empty_element?
      when XML::Reader::TYPE_END_ELEMENT
	path = stack.join('/')
	case path
	when %r|opml/body(/outline)+|
	  feed = {}
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

    feed_stack = [NamedArray.new(title)]
    OpmlSpeedReader.parse_body(reader, parser_stack) do |feed, depth|
      if feed.size > 1
	raise if ((depth+1) <=> feed_stack.size) == -1
	feed_stack[-1] << Feed.new(feed[:title], feed[:url])
      else
	case (depth+1) <=> feed_stack.size
	when +1
	  raise
	when 0
	  feed_stack.push(NamedArray.new(feed[:title]))
	when -1
	  tmp = feed_stack.pop
	  feed_stack[-1] << tmp
	  feed_stack.push(NamedArray.new(feed[:title]))
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
