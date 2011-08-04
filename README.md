# OPML_speed_reader

Fast OPML parser for importing RSS feeds.

## Getting started
	gem install opml_speed_reader

## [Examples](http://github.com/AustinBlues/OPML-Speed-Reader/tree/masterexamples)
	cd examples
	bundle exec ruby opml_to_yaml.rb < ../test/opml/Google.xml

## Dependencies
- libxml-ruby - Gem
- libxml2 and libxml2-dev - GNOME library to manipulate XML files

## Branches
- master - retains hierarchy/nesting in OPML file
- FLAT - flattens hierarchy, i.e., discards/ignores nesting.

## License

GPL version 2
