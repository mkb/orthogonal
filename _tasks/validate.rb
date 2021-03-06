require 'jekyll'
require 'w3c_validators'
include W3CValidators

task :validate => ['validate:all']

namespace :validate do
  desc "W3C validation of the output folder"
  task :all => [:setup] do
    validate_type '*.html'
    validate_type '*.css'
    validate_type 'atom.xml'
  end
  
  task :index => [:setup] do
    filename = "public/index.html"
    results = validate_file(filename)
    report(results, filename)
  end
  
  task :file, [:filename] => [:setup] do |t, args|
    results = validate_file(args.filename)
    report(results, args.filename)
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
def yellow(text); colorize(text, "\e[33m"); end
def blue(text); colorize(text, "\e[34m"); end
def purple(text); colorize(text, "\e[35m"); end
def cyan(text); colorize(text, "\e[36m"); end
def cracker(text); colorize(text, "\e[37m"); end

def validate_type(ext)
  files(@config['destination'], ext).each do |file|
    results = validate_file(file)
    report(results, file)
  end  
end

def files(dir, match)
  glob = File.join(dir, "**", match)
  Dir[glob].reject { |f| File.directory?(f) or f =~ /(~|\.orig|\.rej|\.bak)$/ }
end

class String
  def dumb_pluralize(quantity)
    (quantity != 1) ? "#{self}s" : self
  end
end

def report(results, filename)
  return if results.nil?
  
  err_count = results.errors.length
  warn_count = results.warnings.length
  if err_count > 0 or warn_count > 0
    print "  #{cyan(filename)}:  #{err_count} #{'error'.dumb_pluralize(err_count)}, "
    puts "#{warn_count} #{'warning'.dumb_pluralize(warn_count)}"

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
    validator = @feed_validator
  elsif filename.end_with? '.css'
    validator = @css_validator
    return
  else
    validator = @markup_validator
  end
  
  validator.validate_file(filename)
end
