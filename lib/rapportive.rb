require "rapportive/version"
require "rapportive/rapportive_api.rb"

module Rapportive

  def self.lookup(first_name, last_name, domain)
    RapportiveApi.new.query(first_name,last_name,domain)
  end

end
