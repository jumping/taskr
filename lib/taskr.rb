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

$APP_NAME ||= 'taskr'
$APP_ROOT ||= File.expand_path(File.dirname(__FILE__)+'/..')

$: << $APP_ROOT+"/lib"

require 'taskr/prep'

# Initialize Taskr

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

if $CONF[:authentication]
  Taskr.authenticate_using($CONF[:authentication][:method] || :basic)
end


def Taskr.create
  $LOG.info "Initializing Taskr..."
  Taskr::Models::Base.establish_connection($CONF.database)
  
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
end

