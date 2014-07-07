require 'httparty'

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

      return {'contact' => {'email' => "Nothing found" }} if response == "Nothing found"

      if options[:full_body]
        return response.parsed_response 
      else
        return response.parsed_response['contact']['email']
      end

    end


  private
    def execute_query(first_name, last_name, middle_name, domain, proxy_addr= nil, proxy_port= nil, timeout=20)
      first_name.delete!(" ")
      last_name.delete!(" ")
      middle_name.delete!(" ")
      domain.delete!(" ")

      timeout = Rapportive.options[:timeout]
      tries = Rapportive.options[:tries]

      puts 'proxy in use:'+ proxy_addr+':'+proxy_port if (proxy_addr && proxy_port)
      
      begin
        email_found = "Nothing found"
        login_response = HTTParty.get('https://rapportive.com/login_status?user_email=' + generate_email, http_proxyaddr: proxy_addr, http_proxyport: proxy_port, timeout: timeout)
       
        if login_response.success?
          session_token = login_response["session_token"]

          strip_templates = stripped_templates(first_name, last_name, middle_name)
          
          for template_email in strip_templates
            
            puts 'template email lenght:'+ strip_templates.length.to_s

            target_email = template_email % { fn: first_name, ln: last_name, mn: middle_name, fi: first_name[0] || '', li: last_name[0] || '', mi: middle_name[0] || '' } + '@' + domain
            puts 'trying: '+ target_email

            begin

              email_response = HTTParty.get('https://profiles.rapportive.com/contacts/email/' + target_email, :headers => { "X-Session-Token" => session_token}, http_proxyaddr: proxy_addr, http_proxyport: proxy_port, timeout: timeout)
            
              if email_response.success?
                if email_response["contact"]["first_name"].length == 0 && email_response["contact"]["first_name"].length == 0
                  email_found = "Nothing found"
                else
                  email_found = email_response
                  break
                end
              else
                #raise Rapportive::HttpError, email_response.code
              end
            rescue StandardError => e 
              tries -= 1
              if tries > 0
                puts 'StandardError '+ e.message + ' retrying...' + ' remaining attempts: ' + tries.to_s
                retry
              end
            end
          end
        else
          #raise Rapportive::HttpError, login_response.code
        end
      rescue StandardError => e 
        tries -= 1
        if tries > 0
          puts 'StandardError '+ e.message + ' retrying...' + ' remaining attempts: ' + tries.to_s
          retry
        end
      end
      email_found
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