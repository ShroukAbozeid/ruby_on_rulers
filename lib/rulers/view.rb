module Rulers
  class View
    def set_vars(instance_vars)
      instance_vars.each do |name, value|
        instance_variable_set name.to_sym, value
      end
    end

    def evaluate(template)
      eruby = Erubis::Eruby.new(template)
      eval eruby.src
    end

    def h(str)
      CGI.escape str
    end
  end
end
