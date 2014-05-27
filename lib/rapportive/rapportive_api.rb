require 'faraday'
require 'em-synchrony'
require 'em-synchrony/em-http'
require 'em-synchrony/fiber_iterator'
require 'benchmark'
require 'uri'
require 'httparty'
require 'faraday_middleware'

module Rapportive

  class RapportiveApi
 
    def query_multi_proxy(first_name= "", last_name= "", middle_name= "", domain, options)
      
      puts 'multiproxy'

      proxies = options[:proxy_list]

      begin
        proxy = proxies.first
        raise Rapportive::HttpError, '429 and no more proxy' if proxy.nil?
        proxies.delete(proxy)
        proxy_addr = proxy.split(':').first
        proxy_port = proxy.split(':').last
        response = execute_query(first_name, last_name, middle_name, domain, proxy_addr, proxy_port)
      end while response.nil? || proxies.first.nil?
      
      return response || "Nothing found and no more proxy"
    
    end

    def query_no_proxy(first_name= "", last_name= "", middle_name= "", domain, options)
      response = execute_query(first_name, last_name, middle_name, domain)
      return response || "Nothing found"
    end

    def query_single_proxy(first_name= "", last_name= "", middle_name= "", domain, options)
      proxy_addr = options[:proxy].split(':').first
      proxy_port = options[:proxy].split(':').last
      timeout = options[:timeout]
      attempts = options[:attempts]
      response = execute_query(first_name, last_name, middle_name, domain, proxy_addr, proxy_port)
    end


  private
    def execute_query(first_name, last_name, middle_name, domain, proxy_addr= nil, proxy_port= nil, timeout=20)

      first_name.delete!(" ")
      last_name.delete!(" ")
      middle_name.delete!(" ")
      domain.delete!(" ")

      timeout = Rapportive.options[:timeout]
      tries = Rapportive.options[:tries]

      email_found = "Nothing found"

      login_response = HTTParty.get('https://rapportive.com/login_status?user_email=' + generate_email, http_proxyaddr: proxy_addr, http_proxyport: proxy_port, timeout: timeout)

      if login_response.success?

        session_token = login_response["session_token"]
        
        strip_templates = stripped_templates(first_name, last_name, middle_name)
        
        opts = {
          :proxy => { :host => '198.7.62.203', :port => 333 }, head: { 'X-Session-Token' => session_token }
        }



        EventMachine.run do
          
          Fiber.new{
            template_emails = strip_templates
            
            finished = template_emails.length
            
            responses = []
      
            template_emails.map do |template_email|

              target_email = template_email % { fn: first_name, ln: last_name, mn: middle_name, fi: first_name[0] || '', li: last_name[0] || '', mi: middle_name[0] || '' } + '@' + domain
              
              puts target_email

              if email_found == "Nothing found"

                response = EventMachine::HttpRequest.new("https://profiles.rapportive.com/contacts/email/" + target_email).get opts
          
                responses.push response

                response.callback do

                  puts 'response is here..'

                  body = JSON.parse(response.response)
                  
                  if body["contact"]["first_name"].length == 0 && body["contact"]["first_name"].length == 0
                    email_found = "Nothing found"
                  else
                    email_found = body["contact"]["email"]
                    puts 'found!!!!!!!!!!! '+ email_found
                    EM.stop_event_loop
                  end

                  finished -= 1
                  if finished == 0
                    email_found = "Nothing found"
                    EventMachine.stop_event_loop
                  end
                
                end

              end

              # response.errback do
              #   puts response.inspect
                
              #   puts 'hey error i will login again'

              #   login_response = HTTParty.get('https://rapportive.com/login_status?user_email=' + generate_email, http_proxyaddr: proxy_addr, http_proxyport: proxy_port, timeout: timeout)
                
              #   if login_response.success?
              #     puts 'logged in'
              #     session_token = login_response["session_token"]
                  
              #     opts = {
              #       :proxy => { :host => '198.7.62.203', :port => 333 }, head: { 'X-Session-Token' => session_token }
              #     }
              #   else
              #     puts 'the connection is fucked up'
              #     EventMachine.stop
              #   end
              # end
              
            end
          }.resume

        end

        puts 'ended '+email_found
      email_found

    end






      # login_response = HTTParty.get('https://rapportive.com/login_status?user_email=' + generate_email, http_proxyaddr: proxy_addr, http_proxyport: proxy_port, timeout: timeout)
       
      #   if login_response.success?
      #     session_token = login_response["session_token"]

      #     strip_templates = stripped_templates(first_name, last_name, middle_name)

      #     EM.synchrony do
            

      #       puts 'in synchrony'
            
      #       results = []
            
      #       conn.in_parallel do
      #         for template_email in strip_templates[0..2]

      #           target_email = template_email % { fn: first_name, ln: last_name, mn: middle_name, fi: first_name[0] || '', li: last_name[0] || '', mi: middle_name[0] || '' } + '@' + domain
      #           puts 'trying: '+ target_email

      #           response = Faraday.get do |req|
      #             req.url 'https://profiles.rapportive.com/contacts/email/' + target_email
      #             req.headers['X-Session-Token'] = session_token

      #             req.options[:proxy] = "http://"+proxy_addr.to_s+":"+proxy_port.to_s
      #           end

      #           results.push response

      #           response.on_complete do |resp|
      #             if resp.success?
      #               puts 'response is here..'
      #               body = JSON.parse(resp.body)
      #               puts body["contact"]["first_name"]
      #               EM.stop_event_loop
      #             end
      #           end

      #         end
      #       end

      #       # results.each do |result|
      #       #   if result.success?
      #       #     body = JSON.parse(result.body)
      #       #     puts body["contact"]["first_name"]
      #       #   end
      #       # end
      #     puts 'stop!!!!!!!'
      #     EM.stop
      #     end

      #     puts 'where are i am'

      #   end

    end





    def generate_email(size = 6)
      charset = %w{ 1 2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z a b c d e f g h j k l m p q r s t v z}
      (0...size).map{ charset.to_a[rand(charset.size)] }.join + '@gmail.com'
    end

public

    def stripped_templates(first_name, last_name, middle_name)
      templates = Rapportive.options[:email_templates]
      templates = templates.select{|i| !(i.include?('mi') || i.include?('mn'))} if middle_name.empty?
      templates = templates.select{|i| !(i.include?('fi') || i.include?('fn'))} if first_name.empty?
      templates = templates.select{|i| !(i.include?('li') || i.include?('ln'))} if last_name.empty?
      templates
    end

  end

end