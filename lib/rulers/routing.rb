# frozen_string_literal: true

module Rulers
  class Application
    def get_controller_and_action(env)
      _, cont, action, = env["PATH_INFO"].split("/", 4)
      cont = cont.capitalize
      cont += "Controller"
      [Object.const_get(cont), action]
    end

    def find_root_page(env)
      Object.const_get("HomeController").new(env).send("index")
    rescue NameError
      Object.const_get("PagesController").new(env).send("home")
    end
  end
end
