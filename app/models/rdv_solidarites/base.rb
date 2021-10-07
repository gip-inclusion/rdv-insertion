module RdvSolidarites
  class Base
    attr_reader :attributes

    def initialize(attributes = {})
      @attributes = attributes.deep_symbolize_keys
      self.class::RECORD_ATTRIBUTES.each do |attr_name|
        next unless @attributes.include?(attr_name)

        instance_variable_set("@#{attr_name}", @attributes[attr_name])
      end
    end
  end
end
