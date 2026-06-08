# frozen_string_literal: true

module Rulers
  def self.to_underscore(string)
    string.gsub(/::/, "/") # replace :: with / for namespacing
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr("-", "_")
          .downcase
  end
end
