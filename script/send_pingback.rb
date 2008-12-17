#!/usr/bin/ruby

require "xmlrpc/client"
 
server = XMLRPC::Client.new2("http://localhost:3000/pingback/xml")

ok, param = server.call2("pingback.ping", "http://localhost/index.html", "http://localhost:3000/stage/chaas-schulz")

if ok then
  puts "Response: #{param}"
else
  puts "Error:"
  puts param.faultCode 
  puts param.faultString
end
