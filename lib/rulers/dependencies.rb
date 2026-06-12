class Object
  def self.const_missing(const_name)
    @calling_const_missing ||= {}
    return nil if @calling_const_missing[const_name]

    @calling_const_missing[const_name] = true
    require Rulers.to_underscore(const_name.to_s)
    klass = Object.const_get(const_name)
    @calling_const_missing[const_name] = false
    klass
  end
end
