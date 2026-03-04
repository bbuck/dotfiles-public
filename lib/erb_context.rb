require "erb"

class ERBContext
  def initialize(hash)
    hash.each_pair do |key, value|
      singleton_class.send(:define_method, key) { value }
    end
  end

  def get_binding
    binding
  end
end

