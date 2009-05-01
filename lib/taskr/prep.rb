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

require 'taskr/load_picnic'
require 'taskr/load_reststop'

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