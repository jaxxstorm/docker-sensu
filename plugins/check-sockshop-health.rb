#!/usr/bin/env ruby
#
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'rest-client'
require 'json'

class SockShopServiceStatus < Sensu::Plugin::Check::CLI

option :hostname,
  :short => '-h HOSTNAME',
  :long  => '--hostname HOSTNAME',
  :description => 'The hostname of the c2 agent to query',
  :default => 'localhost'

option :port,
  :short => '-p PORT',
  :long  => '--port PORT',
  :description  => 'The port the c2 agent is listening on',
  :default => '80'

option :timeout,
  :short => '-t TIMEOUT',
  :long => '--timeout TIMEOUT',
  :description => 'How long to wait before timing out',
  :default => 10

option :threshold,
  :short => '-T THRESHOLD',
  :long  => '--threshold THRESHOLD',
  :description => 'The amount of time we should allow between a failed deployment and ignoring',
  :default => 3600


  def run

     # Set some vars from the config
     hostname = config[:hostname]
     port = config[:port]
     timeout = config[:timeout].to_i
     threshold = config[:threshold].to_i

     @url = "http://#{hostname}:#{port}/health"

     # Request the status
     r = RestClient::Resource.new(@url, :timeout => timeout, :open_timeout => timeout).get
     if r.code == 200
       output = JSON.parse(r)
       if output['health'][0]['status'].include? "OK"
         ok "Service #{output['health'][0]['service']} responding and reporting healthy"
       else
         critical "Service #{output['health'][0]['service']} responding with #{output['health'][0]['status']}"
       end
     else
       critical "Got response code #{r.code}"
     end # end r.code check

  end # end run def

end
