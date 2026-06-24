# frozen_string_literal: true

class RouteObject
  def initialize
    @rules = []
  end

  def match(url, *args)
    options = {}
    options = args.pop if args[-1].is_a?(Hash)
    options[:default] ||= {}

    dest = nil
    dest = args.pop unless args.empty?
    raise "Too many args" unless args.empty?

    parts = url.split("/")
    parts.reject!(&:empty?)

    vars = []
    regexp_parts = parts.map do |part|
      if part[0] == ":"
        vars << part[1..]
        "([a-zA-Z0-9]+)"
      elsif part[0] == "*"
        vars << part[1..]
        "(.*)"
      else
        part
      end
    end

    regexp = regexp_parts.join("/")
    @rules.push({
                  regexp: Regexp.new("^/#{regexp}$"),
                  vars: vars,
                  dest: dest,
                  options: options
                })
  end

  def root(dest)
    match("/", dest)
  end

  def check_url(url)
    puts @rules
    @rules.each do |rule|
      m = rule[:regexp].match(url)
      next unless m

      options = rule[:options]
      params = options[:default].dup
      rule[:vars].each_with_index do |var, i|
        params[var] = m.captures[i]
      end

      return get_dest(rule[:dest], params) if rule[:dest]

      controller = params[:controller] || params['controller']
      action = params[:action]|| params['action']
      return get_dest("#{controller}##{action}", params)
    end

    nil
  end

  def get_dest(dest, routing_params = {})
    return dest if dest.respond_to?(:call)

    if dest =~ /^([^#]+)#([^#]+)$/
      name = ::Regexp.last_match(1).capitalize
      con = Object.const_get("#{name}Controller")
      return con.action(::Regexp.last_match(2), routing_params)
    end

    raise "Invalid route: #{dest.inspect}"
  end
end

module Rulers
  class Application
    def get_controller_and_action(env)
      _, cont, action, = env["PATH_INFO"].split("/", 4)
      cont = cont.capitalize
      cont += "Controller"
      [Object.const_get(cont), action]
    end

    def route(&block)
      @route_obj ||= RouteObject.new
      @route_obj.instance_eval(&block)
    end

    def get_rack_app(env)
      raise "No routes" unless @route_obj

      @route_obj.check_url(env["PATH_INFO"])
    end
  end
end
