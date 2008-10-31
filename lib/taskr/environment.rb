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

$: << File.dirname(File.expand_path(__FILE__))

# Try to load local version of Picnic if possible (for development purposes)
alt_picnic_paths = [
  File.dirname(File.expand_path(__FILE__))+"/../../../picnic/lib",
  File.dirname(File.expand_path(__FILE__))+"/../../vendor/picnic/lib"
]
# Try to load local version of Reststop if possible (for development purposes)
alt_reststop_paths = [
  File.dirname(File.expand_path(__FILE__))+"/../../../reststop/lib",
  File.dirname(File.expand_path(__FILE__))+"/../../vendor/reststop/lib"
]

require 'rubygems'

# make things backwards-compatible for rubygems < 0.9.0
unless Object.method_defined? :gem
  alias gem require_gem
end

if alt_picnic_paths.any?{|path| File.exists? "#{path}/picnic.rb" }
  alt_picnic_paths.each{|path| $: << path}
end
require 'picnic'

if alt_reststop_paths.any?{|path| File.exists? "#{path}/reststop.rb" }
  alt_reststop_paths.each{|path| $: << path}
end

require 'reststop'

require 'active_record'
require 'active_support'

require 'camping/db'

gem 'rufus-scheduler', '>=1.0.7'
require 'rufus/scheduler'
