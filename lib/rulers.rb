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
      status = 200
      body = []
      headers = { "content-type" => "text/html" }
      if env["PATH_INFO"] == "/favicon.ico"
        status = 404
      elsif env["PATH_INFO"] == "/"
        body = [File.read("public/index.html")]
      else
        klass, action = get_controller_and_action(env)
        controller = klass.new(env)
        body = [controller.send(action)]
        res = controller.get_response
        if res
          status = res.status
          headers = res.headers
          body = [res.body].flatten
        end
      end

      [status, headers, body]
    end

    def self.framework_root
      __dir__
    end
  end
end
