require "rapportive/version"
require "rapportive/rapportive_api.rb"
require "rapportive/configuration"

module Rapportive
  
  extend Configuration

  def self.lookup(first_name, last_name, middle_name, domain, proxy= false)

    first_name.delete(' ')
    last_name.delete(' ')
    middle_name.delete(' ')
    domain.delete(' ')

    if options[:method] == :multi_proxy  
      RapportiveApi.new.query_multi_proxy(first_name, last_name, middle_name, domain, options)
    elsif options[:method] == :single_proxy
      RapportiveApi.new.query_single_proxy(first_name, last_name, middle_name, domain, options)
    elsif options[:method] == :no_proxy
      RapportiveApi.new.query_no_proxy(first_name, last_name, middle_name, domain, options)
    else
      raise 'unknown method did you set-up multi_proxy or single proxy or no proxy config?'
    end

  end

  class HttpError < StandardError

  end

end
