require_relative 'constants'

module Rapportive
  # Defines constants and methods related to configuration
  module Configuration

    # An array of valid keys in the options hash when configuring a {AngellistApi::API}
    VALID_OPTIONS_KEYS = [
      :method,
      :proxy,
      :proxy_list,
      :email_templates,
      :timeout,
      :full_body,
      :tries
    ]

    attr_accessor *VALID_OPTIONS_KEYS

    # When this module is extended, set all configuration options to their default values
    def self.extended(base)
      base.reset
    end

    # Convenience method to allow configuration options to be set in a block
    def configure
      yield self
    end

    # Create a hash of options and their values
    def options
      options = {}
      VALID_OPTIONS_KEYS.each{|k| options[k] = send(k)}
      options
    end

    # Reset all configuration options to defaults
    def reset
      self.method = :single_proxy
      self.proxy = "198.7.62.203:333"
      self.proxy_list = PROXIES_LIST.dup
      self.email_templates = EMAIL_TEMPLATES.dup
      self.timeout = 30
      self.tries = 5
      self.full_body = false
      self
    end
  end
end