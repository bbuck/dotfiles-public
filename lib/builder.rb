# Extendable module for classes that add a BaseBuilder implementation
module Buildable
  def build(&block)
    builder = self::Builder.build(&block)
    self.new(builder)
  end
end

# Contains helpers for defining builders concisely
class BaseBuilder
  class << self
    attr_reader :attributes, :multivalue_attributes

    def builds_attributes(attributes)
      @attributes = attributes.map(&:to_sym)

      define_attribute_setters
      define_attribute_getters
    end

    def builds_multivalue_attributes(attributes)
      @multivalue_attributes = attributes.map(&:to_sym)

      define_multivalue_attribute_setters
      define_multivalue_attribute_getters
    end

    def build(&block)
      builder = self.new
      builder.instance_eval(&block) if block_given?
      builder
    end

    private

    def define_attribute_setters
      attributes.each do |attribute_name|
        define_method("#{attribute_name}") do |*args, &block|
          value =
            if block
              block
            else
              args.empty? ? nil : args.first
            end
          instance_variable_set(
            "@#{attribute_name}",
            value
          )
          self
        end
      end
    end

    def define_attribute_getters
      attributes.each do |attribute_name|
        define_method("get_#{attribute_name}") do
          instance_variable_get("@#{attribute_name}")
        end
      end
    end

    def define_multivalue_attribute_setters
      multivalue_attributes.each do |attribute_name|
        attr = :"@#{attribute_name}"
        define_method("#{attribute_name}") do |*args, &block|
          current = instance_variable_get(attr)
          current = [] if current.nil?
          if block
            current << block
          else
            current.push(*args)
          end
          instance_variable_set(attr, current)
          self
        end
      end
    end

    def define_multivalue_attribute_getters
      multivalue_attributes.each do |attribute_name|
        attr = :"@#{attribute_name}"
        define_method("get_#{attribute_name}") do
          instance_variable_get(attr)
        end
      end
    end
  end
end
