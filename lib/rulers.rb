# frozen_string_literal: true

require_relative "rulers/version"
require_relative "rulers/array"
require "rulers/version"
require "rulers/routing"
module Rulers
  class Error < StandardError; end

  class Application
    def call(env)
      if env["PATH_INFO"] == "/favicon.ico"
        return [404,
                { "content-type" => "text/html" }, []]
      end
      klass, action = get_controller_and_action(env)
      controller = klass.new(env)
      text = controller.send(action)
      [200, { "content-type" => "text/html" }, [text]]
    end
  end

  class Controller
    def initialize(env)
      @env = env
    end

    attr_reader :env
  end
end
