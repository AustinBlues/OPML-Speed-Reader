# OPML_speed_reader

Fast OPML parser for importing RSS feeds.

## Getting started

	gem install opml_speed_reader

- [Examples](http://github.com/austinblues/opml_speed_reader/examples)
    ruby examples/opml_to_yaml.rb < XYZ.xml

## Dependencies

- libxml-ruby - Gem
- libxml2 and libxml2-dev - GNOME library to manipulate XML files

## TODO
- Retain hierarchy/nesting in OPML file; current release flattens
  hierarchy, i.e., discards/ignores nesting.
- Split current non-nesting code into own branch.

### License

GPL version 2
