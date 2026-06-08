# frozen_string_literal: true

require_relative "rulers/version"
require_relative "rulers/array"
require "rulers/version"
require "rulers/routing"
require "rulers/util"
require "rulers/dependencies"
module Rulers
  class Error < StandardError; end

  class Application
    def call(env)
      status = 200
      body = []
      if env["PATH_INFO"] == "/favicon.ico"
        status = 404
      elsif env["PATH_INFO"] == "/"
        body = [find_root_page(env)]
      else
        klass, action = get_controller_and_action(env)
        controller = klass.new(env)
        body = [controller.send(action)]
      end

      [status, { "content-type" => "text/html" }, body]
    end
  end

  class Controller
    def initialize(env)
      @env = env
    end

    attr_reader :env
  end
end
