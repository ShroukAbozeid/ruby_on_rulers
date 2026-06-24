# frozen_string_literal: true

require_relative "rulers/version"
require_relative "rulers/array"
require "rulers/version"
require "rulers/routing"
require "rulers/util"
require "rulers/dependencies"
require "rulers/controller"
require "rulers/file_model"
require "rulers/view"
module Rulers
  class Error < StandardError; end

  class Application
    def call(env)
      return [404, { "Content-Type" => "text/html" }, []] if env["PATH_INFO"] == "/favicon.ico"

      rack_app = get_rack_app(env)
      rack_app.call(env)
    end

    def self.framework_root
      __dir__
    end
  end
end
