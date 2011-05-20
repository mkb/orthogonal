require 'jekyll'
require 'w3c_validators'
include W3CValidators

task :validate => ['validate:default']

namespace :validate do
  desc "W3C validation of the output folder"
  task :all => [:setup] do
    # perform a setup of all our variables
    validate_type '*.html'
    validate_type '*.css'
    validate_type 'atom.xml'
  end
  
  task :default => [:setup] do
    filename = "public/index.html"
    results = validate_file(filename)
    report(results, filename)
  end
  
  task :setup do
    @config = Jekyll.configuration({})
    @css_validator = CSSValidator.new
    @markup_validator = MarkupValidator.new
    @feed_validator = FeedValidator.new
  end
end


private

# Colorize the output :)
def colorize(text, color_code); "#{color_code}#{text}\e[0m"; end
def red(text); colorize(text, "\e[31m"); end
def green(text); colorize(text, "\e[32m"); end
def cyan(text); colorize(text, "\e[36m"); end


# Method to validate calling to the w3c_validators methods
def validate_type(ext)
  files(@config['destination'], ext).each do |file|
    results = validate_file(file)
    report(results)
  end  
end

def report(results, filename)
  err_count = results.errors.length
  if err_count > 0
    if err_count == 1
      puts "  #{cyan(filename)}:  #{results.errors.length} error"
    else
      puts "  #{cyan(filename)}:  #{results.errors.length} errors"
    end
    results.errors.each do |err|
      emit_message(err)
    end
    results.warnings.each do |warn|
      emit_message(warn)
    end
  else
    puts "  #{cyan(filename)} => #{green('Valid!')}"
  end
end

def emit_message(message)
  output = "    - #{message.type}; line #{message.line}:  #{message.message}"
  puts (message.type == :error) ? red(output) : yellow(output)
end

def validate_file(filename)
  if filename.end_with? 'atom.xml'
    validator = @markup_validator
  elsif filename.end_with? '.css'
    validator = @css_validator
  else
    validator = @markup_validator
  end
  
  validator.validate_file(filename)
end

def files(dir, match)
  glob = File.join(dir, "**", match)
  Dir[glob].reject { |f| File.directory?(f) or f =~ /(~|\.orig|\.rej|\.bak)$/ }
end
