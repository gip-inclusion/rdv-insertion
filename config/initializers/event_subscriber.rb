module EventSubscriber
  extend ActiveSupport::Concern

  included do
    attr_reader :params

    include Sidekiq::Worker

    Wisper.subscribe(new)
  end

  class_methods do
    def catch_events(*event_names, **conditions)
      define_run_if_method(conditions)

      event_names.each do |event_name|
        define_method(event_name.to_s) do |subject|
          should_run = respond_to?(:run_if) ? run_if(subject) : true
          attributes = subject.attributes.merge(previous_changes: subject&.previous_changes || {})

          self.class.perform_async(attributes) if should_run
        end

        define_subject_method(event_name)
      end
    end

    def define_run_if_method(options = {})
      return unless options[:if]

      define_method(:run_if) do |subject|
        options[:if].call(subject)
      end
    end

    def define_subject_method(event_name)
      resource_name = event_name.to_s.split("_").second.singularize.downcase
      return if method_defined?(resource_name)

      define_method(resource_name) do
        model = event_name.to_s.split("_").second.singularize.camelize.constantize
        @subject ||= model.find_by(id: params["id"])
      end
      alias_method :subject, resource_name
    end
  end

  #
  # This is the method that will be called when an event is triggered
  # It will be executed in the background by Sidekiq
  #
  # @params [Hash] params The attributes of the model that triggered the event + the previous_changes
  #
  def perform(params)
    @params = params
    process_event
  end
end
Dir["app/events/**/*.rb"].each { |file| load file }

Wisper::ActiveRecord.extend_all
