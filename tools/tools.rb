require File.dirname(__FILE__)+'/command_line_parser.rb'

if ARGV.length < 1
  puts 'usage: cohsa command [options]'
  puts 'type cohsa help to get help'
  exit
end

CohsaCommandLineParser.new ARGV

