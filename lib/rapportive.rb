require "rapportive/version"
require "rapportive/rapportive_api.rb"

module Rapportive

  def self.lookup(first_name, last_name, domain, proxy= false)
    if proxy    
      RapportiveApi.new.query_proxy(first_name,last_name,domain)
    else
      RapportiveApi.new.query_no_proxy(first_name,last_name,domain)
    end

  end

  class HttpError < StandardError

  end

end
