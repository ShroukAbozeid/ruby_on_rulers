# frozen_string_literal: true

require_relative "rulers/version"
require_relative "rulers/array"
require "rulers/version"
require "rulers/routing"
require "rulers/util"
require "rulers/dependencies"
require "rulers/controller"
module Rulers
  class Error < StandardError; end

  class Application
    def call(env)
      status = 200
      body = []
      if env["PATH_INFO"] == "/favicon.ico"
        status = 404
      elsif env["PATH_INFO"] == "/"
        body = [File.read("public/index.html")]
      else
        klass, action = get_controller_and_action(env)
        controller = klass.new(env)
        body = [controller.send(action)]
      end

      [status, { "content-type" => "text/html" }, body]
    end

    def self.framework_root
      __dir__
    end
  end
end
