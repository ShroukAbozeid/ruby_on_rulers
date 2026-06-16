# frozen_string_literal: true

require "erubis"
require "rulers/file_model"

module Rulers
  class Controller
    include Rulers::Model
    def initialize(env)
      @env = env
    end

    attr_reader :env

    def render(view_name, _locals = {})
      filename = File.join(
        "app", "views", controller_name, "#{view_name}.html.erb"
      )
      template = File.read filename
      v = View.new
      v.set_vars instance_hash
      v.evaluate template
    end

    def instance_hash
      h = {}
      instance_variables.each do |i|
        h[i] = instance_variable_get i
      end
      h
    end

    def controller_name
      klass = self.class
      klass = klass.to_s.gsub(/Controller$/, "")
      Rulers.to_underscore(klass)
    end

    def instance_vars
      vars = {}
      instance_variables.each do |name|
        vars[name[1..]] =
          instance_variable_get name.to_sym
      end
      vars
    end

    def request
      @request ||= Rack::Request.new(@env)
    end

    def response(text, status = 200, headers = {})
      raise "Already responded" if @response

      # not working undefined constant Rack::Response
      @response = Rack::Response.new([text].flatten, status, headers)
    end

    def get_response
      @response
    end

    def render_response(*args)
      response(render(*args))
    end

    def params
      request.params
    end
  end
end
