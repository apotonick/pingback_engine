class PingbackController < ApplicationController
  # great help for using xml-rpc in Rails:
  # http://blog.multiplay.co.uk/2008/10/serving-xml-rpc-from-rails-2x/
  
  require "xmlrpc/server"
  
  def xml
    xmlrpc = XMLRPC::BasicServer.new
    
    ### FIXME: move to initializer/environment.rb or whereever this belongs to:
      Pingback.save_callback do |ping|
        comment = Comment.new
        comment.author = ping.title
        comment.author_url = ping.source_uri
        comment.text = ping.content
        
        comment.product_review_id = nil
        
        puts comment.inspect
      end
    
    
    xmlrpc.add_handler("pingback.ping") do |source_uri, target_uri|
      Pingback.new(source_uri, target_uri).receive_ping
    end
    
    xml_response = xmlrpc.process(request.body.read)
    
    # Log the error if there is one
    parser = XMLRPC::XMLParser::XMLStreamParser.new
    ret = parser.parseMethodResponse(xml_response)
    logger.error("XMLRPC fault raised. Code: #{ret[1].faultCode}: Message: #{ret[1].faultString}") unless ret[0]
    
    response.content_type = "text/xml; charset=utf-8"
    render :text => xml_response, :layout => false
  end

end
