require 'jekyll'
require 'w3c_validators'
include W3CValidators
require 'pp'

desc "W3C validation of the output folder"
task :validate do
  # perform a setup of all our variables
  setup
  validate '.html'
  validate '.css'
end

task :gug do
  setup
  @validator = MarkupValidator.new
  @validator.set_debug!(true)
  file = File.dirname(__FILE__) + '/../_site/index.html'
  results = @validator.validate_file(file)
  
  if results.errors.length > 0
    results.errors.each do |err|
      puts "#{err.pretty_inspect}"
    end
  else
    puts 'Valid!'
  end

  puts "#{results.errors.length} errors."

  puts 'Debugging messages'

  results.debug_messages.each do |key, value|
    puts "#{key}: #{value}"
  end
end

private

# Colorize the output :)
def colorize(text, color_code); "#{color_code}#{text}\e[0m"; end
def red(text); colorize(text, "\e[31m"); end
def green(text); colorize(text, "\e[32m"); end

# Reads the yaml with the configuration of the project to get always the correct
# output_dir and initializes the validator
def setup
  @config = Jekyll.configuration({})
end


# Method to validate calling to the w3c_validators methods
def validate ext
  @validator = (ext == ".css" ? CSSValidator.new : MarkupValidator.new )
  
  files(@config['destination'], true, ext).each do |file|
    results = @validator.validate_file(file)
    if results.errors.length > 0
        results.errors.each do |err|
          puts "\t #{file} => #{red(err)}"
        end
      else
        puts "\t #{file} => #{green('Valid!')}"
      end
  end
  
end

# From nanoc
# # Returns a list of all files in +dir+, ignoring any unwanted files (files
# that end with '~', '.orig', '.rej' or '.bak').
#
# +recursively+:: When +true+, finds files in +dir+ as well as its
#                 subdirectories; when +false+, only searches +dir+
#                 itself.

def files(dir, recursively, ext = '')
  glob = File.join([dir] + (recursively ? [ "**", "*#{ext}" ] : [ "*#{ext}" ]))
  Dir[glob].reject { |f| File.directory?(f) or f =~ /(~|\.orig|\.rej|\.bak)$/ }
end
