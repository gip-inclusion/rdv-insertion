module Callbacks
  extend ActiveSupport::Concern

  class_methods do
    def before_calls
      @before_calls ||= []
    end

    def before_call(*instance_methods)
      instance_methods.each { |instance_method| before_calls << instance_method }
    end
  end

  def call_before_calls
    self.class.before_calls.each do |before_call|
      send(before_call)
    end
  end
end
