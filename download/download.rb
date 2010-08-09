#!/usr/bin/ruby
require 'pathname'
parent = Pathname.new(__FILE__).parent
$LOAD_PATH << parent << parent.parent

require 'rubypuz/crossword_store'
require 'downloader'
require 'wanted'

datadir = ARGV.shift || ENV['DATADIR']
store = CrosswordStore.new(datadir)
Downloader.load_downloaders
Downloader.update_all(ARGV, store)
