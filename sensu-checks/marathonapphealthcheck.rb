#!/usr/bin/env ruby
#Sensu check for Marathon app running or not
require "net/http"
require "uri"
require "json"
require 'sensu-plugin/check/cli'
class MarathonAppHealthCheck   < Sensu::Plugin::Check::CLI
  option :id,
         description: 'applicaton id',
         short: '-i Marathon app ID',
         long: '--id Marathon app ID',
         required: true
  option :server,
         description: 'Marathon hosts, comma separated',
         short: '-s SERVER',
         long: '--server SERVER',
         default: 'localhost'
     option :port,
         description: 'Marathon port',
         short: '-p PORT',
         long: '--port PORT',
         default: '8080'
def run

uri = URI.parse("http://#{config[:server]}:#{config[:port]}/v2/apps/#{config[:id]}/tasks")
response = Net::HTTP.get_response(uri)
data_hash = JSON.parse(response.body)

#If No tasks are running
 if data_hash['tasks'][0].nil?
  critical "NO task running for #{config[:id]}. Please check"	
 end

data_hash['tasks'].each do |health|
  health['healthCheckResults'].each do |live|
	alive = live['alive']
#If True	
     if alive == true
     ok "#{config[:id]} running healthy"	
      
#If false
	elsif alive == false
	critical "#{config[:id]} NOT running, Health Check failed. Please check"
	else 
	unknown "kindly check, exit status is unknown"
	end

#end of both loops
end
end
#end of class, run
end
end
