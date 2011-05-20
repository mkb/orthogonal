require 'jekyll'
require 'w3c_validators'
include W3CValidators

task :validate => ['validate:default']

namespace :validate do
  desc "W3C validation of the output folder"
  task :all => [:setup] do
    # perform a setup of all our variables
    validate_type '.html'
    validate_type '.css'
  end
  
  task :default => [:setup] do
    results = validate_file(File.new("public/index.html"))
    report(results)
  end
  
# Reads the yaml with the configuration of the project to get always the correct
# output_dir
  task :setup do
    @config ||= Jekyll.configuration({})
    @css_validator = CSSValidator.new
    @markup_validator = MarkupValidator.new
  end
end


private

# Colorize the output :)
def colorize(text, color_code); "#{color_code}#{text}\e[0m"; end
def red(text); colorize(text, "\e[31m"); end
def green(text); colorize(text, "\e[32m"); end


# Method to validate calling to the w3c_validators methods
def validate_type(ext)
  files(@config['destination'], true, ext).each do |file|
    results = validate_file(file)
    report(results)
  end  
end

def report(results)
  if results.errors.length > 0
    results.errors.each do |err|
      puts "\t #{file.path} => #{red(err)}"
    end
  else
    puts "\t #{file.path} => #{green('Valid!')}"
  end
end

def validate_file(file)
  if file.path.end_with? '.css'
    validator = @css_validator
  else
    validator = @markup_validator
  end
  
  validator.validate_file(file)
end

def files(dir, recursively, ext = '')
  glob = File.join([dir] + (recursively ? [ "**", "*#{ext}" ] : [ "*#{ext}" ]))
  Dir[glob].reject { |f| File.directory?(f) or f =~ /(~|\.orig|\.rej|\.bak)$/ }
end
