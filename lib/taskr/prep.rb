# This file is part of Taskr.
#
# Taskr is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Taskr is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Taskr.  If not, see <http://www.gnu.org/licenses/>.

# Load Picnic
unless Object.const_defined?(:Picnic)
  if File.exists?(picnic = File.expand_path(File.dirname(File.expand_path(__FILE__))+'/../../vendor/picnic/lib'))
    $: << picnic
  elsif File.exists?(picnic = File.expand_path(File.dirname(File.expand_path(__FILE__))+'/../../../picnic/lib'))
    $: << picnic
  else
    require 'rubygems'
    
    # make things backwards-compatible for rubygems < 0.9.0
    if respond_to?(:require_gem)
      puts "WARNING: aliasing 'gem' to 'require_gem' in #{__FILE__} -- you should update your RubyGems system!"
      alias gem require_gem
    end
   
    gem 'picnic'
  end
  
  require 'picnic'
end

# Load Reststop
if File.exists?(reststop = File.expand_path(File.dirname(File.expand_path(__FILE__))+'/../../vendor/reststop/lib'))
  $: << reststop
elsif File.exists?(reststop = File.expand_path(File.dirname(File.expand_path(__FILE__))+'/../../../reststop/lib'))
  $: << reststop
else
  require 'rubygems'
  
  # make things backwards-compatible for rubygems < 0.9.0
  if respond_to?(:require_gem)
    puts "WARNING: aliasing gem to require_gem in #{__FILE__} -- you should update your RubyGems system!"
    alias gem require_gem
  end
 
  gem 'reststop'
end

require 'reststop'

# Load Rufus Scheduler
gem 'rufus-scheduler', '>=1.0.7'
require 'rufus/scheduler'


# Load configuration
unless $CONF
  unless $APP_NAME && $APP_ROOT
    raise "Can't load the Taskr configuration because $APP_NAME and/or $APP_ROOT are not defined."
  end

  require 'picnic/conf'
  $CONF = Picnic::Conf.new
  $CONF.load_from_file($APP_NAME, $APP_ROOT)
end

$CONF.merge_defaults(
  :log      => {:file => 'taskr.log', :level => 'DEBUG'},
  :uri_path => "/",
  :static   => {:root => $APP_ROOT, :urls => "/public"}
)

require 'yaml'
require 'markaby'
require 'picnic/logger'
require 'picnic/authentication'