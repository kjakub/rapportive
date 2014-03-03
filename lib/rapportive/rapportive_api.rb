require 'httparty'

module Rapportive

  class RapportiveApi
 
    TEMPLATES = [
      '%{fn}',
      '%{ln}',
      '%{fn}%{ln}',
      '%{fn}.%{ln}',
      '%{ln}.%{fn}',
      '%{ln}%{fn}',
      '%{fn}-%{ln}',
      '%{ln}-%{fn}',
      '%{fn}_%{ln}',
      '%{ln}_%{fn}'
    ];

    def query(first_name, last_name, domain)
      
      login_response = HTTParty.get('https://rapportive.com/login_status?user_email=' + generate_email)
     
      if login_response.success?
        session_token = login_response["session_token"]

        for template_email in TEMPLATES
          target_email = template_email % { fn: first_name, ln: last_name} + '@' + domain
          email_response = HTTParty.get('https://profiles.rapportive.com/contacts/email/' + target_email, :headers => { "X-Session-Token" => session_token})
          
          if email_response.success?
            if email_response["contact"]["first_name"].length == 0 && email_response["contact"]["first_name"].length == 0
              email_found = "Nothing found"
            else
              email_found = target_email
              break
            end
          else
            raise login_response
          end
        
        end

      else
        raise login_response
      end 

      return email_found
    end


    private

      def generate_email(size = 6)
        charset = %w{ 1 2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z a b c d e f g h j k l m p q r s t v z}
        (0...size).map{ charset.to_a[rand(charset.size)] }.join + '@gmail.com'
      end

  end

end