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


unless Object.const_defined?(:Picnic)
  $APP_NAME ||= 'taskr'
  $APP_ROOT ||= File.expand_path(File.dirname(__FILE__)+'/..')
  
  if File.exists?(picnic = File.expand_path(File.dirname(File.expand_path(__FILE__))+'/../vendor/picnic/lib'))
    $: << picnic
  elsif File.exists?(picnic = File.expand_path(File.dirname(File.expand_path(__FILE__))+'/../../picnic/lib'))
    $: << picnic
  else
    require 'rubygems'
    
    # make things backwards-compatible for rubygems < 0.9.0
    if respond_to?(:require_gem)
      puts "WARNING: aliasing gem to require_gem in #{__FILE__} -- you should update your RubyGems system!"
      alias gem require_gem
    end
   
    gem 'picnic'
  end
  
  require 'picnic'
end

unless $CONF
  unless $APP_NAME && $APP_ROOT
    raise "Can't load the RubyCAS-Server configuration because $APP_NAME and/or $APP_ROOT are not defined."
  end

  require 'picnic/conf'
  $CONF = Picnic::Conf.new
  $CONF.load_from_file($APP_NAME, $APP_ROOT)
end

require 'yaml'
require 'markaby'
require 'picnic/logger'
require 'picnic/authentication'

if File.exists?(reststop = File.expand_path(File.dirname(File.expand_path(__FILE__))+'/../vendor/reststop/lib'))
  $: << reststop
elsif File.exists?(reststop = File.expand_path(File.dirname(File.expand_path(__FILE__))+'/../../reststop/lib'))
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


gem 'rufus-scheduler', '>=1.0.7'
require 'rufus/scheduler'

$: << File.dirname(File.expand_path(__FILE__))

Camping.goes :Taskr

Picnic::Logger.init_global_logger!

module Taskr
  @@scheduler = nil
  def self.scheduler=(scheduler)
    @@scheduler = scheduler
  end
  def self.scheduler
    @@scheduler
  end
end

require 'taskr/actions'
require 'taskr/models'
require 'taskr/helpers'
require 'taskr/views'
require 'taskr/controllers'

module Taskr
  include Taskr::Models
  include Picnic::Authentication
  
  def self.authenticate(credentials)
    credentials[:username] == $CONF[:authentication][:username] &&
      credentials[:password] == $CONF[:authentication][:password]
  end
end

include Taskr::Models

if $CONF[:authentication]
  Taskr.authenticate_using($CONF[:authentication][:method] || :basic)
end

$CONF[:public_dir] = {
  :path => "public",
  :dir  => File.join(File.expand_path(File.dirname(__FILE__)),"public")
}

def Taskr.create
  $LOG.info "Initializing Taskr..."
  Taskr::Models::Base.establish_connection($CONF.database)
  
  $LOG.info "Starting Rufus Scheduler..."
  
  Taskr.scheduler = Rufus::Scheduler.new
  Taskr.scheduler.start
  
  $LOG.debug "Scheduler is: #{Taskr.scheduler.inspect}"
  
  tasks = Taskr::Models::Task.find(:all)
  
  $LOG.info "Scheduling #{tasks.length} persisted tasks..."
  
  tasks.each do |t|
    t.schedule! Taskr.scheduler
  end
  
  Taskr.scheduler.instance_variable_get(:@scheduler_thread).run
  
  
  Taskr::Models.create_schema
  
  if $CONF[:external_actions]
    if $CONF[:external_actions].kind_of? Array
      external_actions = $CONF[:external_actions]
    else
      external_actions = [$CONF[:external_actions]]
    end
    external_actions.each do |f|
      $LOG.info "Loading additional action definitions from #{$CONF[:external_actions]}..."
      require f
    end
  end
end

def Taskr.prestart
  
end

