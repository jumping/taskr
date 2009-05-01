if File.exists?(reststop = File.expand_path(File.dirname(File.expand_path(__FILE__))+'/../../vendor/reststop/lib'))
  puts "Loading reststop from #{reststop.inspect}..."
  $: << reststop
elsif File.exists?(reststop = File.expand_path(File.dirname(File.expand_path(__FILE__))+'/../../../reststop/lib'))
  puts "Loading reststop from #{reststop.inspect}..."
  $: << reststop
else
  puts "Loading reststop from rubygems..."
  require 'rubygems'

  begin
    # Try to load dev version of reststop if available (for example 'zuk-reststop' from Github)
    gem /^.*?-reststop$/
  rescue Gem::LoadError
    gem 'reststop'
  end
end