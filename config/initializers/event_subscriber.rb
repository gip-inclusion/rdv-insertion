module EventSubscriber
  extend ActiveSupport::Concern

  included do
    attr_reader :params

    include Sidekiq::Worker

    Wisper.subscribe(new)
  end

  class_methods do
    def catch_changes_on(*classes_to_catch)
      events = []

      classes_to_catch.each do |klass|
        class_name = klass.parameterize.underscore
        events << "create_#{class_name}_successful"
        events << "update_#{class_name}_successful"
        events << "destroy_#{class_name}_successful"
      end

      catch_events(*events.map(&:to_sym))
    end

    def catch_events(*events)
      events.each do |event_name|
        next if check_options(event_name)

        define_method(event_name.to_s) do |subject|
          subject_hash = subject.is_a?(Hash) ? subject : JSON.parse(subject.to_json)
          subject_hash.merge!(previous_changes: subject&.previous_changes || {})
          should_run = respond_to?(:run_if) ? run_if(subject) : true

          self.class.perform_async(subject_hash.with_indifferent_access) if should_run
        end

        define_subject_method(event_name)
      end
    end

    def check_options(event_name)
      if event_name.is_a?(Hash)
        options = event_name

        if options[:if]
          define_method(:run_if) do |subject|
            options[:if].call(subject)
          end
        end

        return true
      end

      false
    end

    def define_subject_method(event_name)
      method_name = event_name.to_s.split("_").second.singularize.downcase
      return if method_defined?(method_name)

      [method_name, "subject"].each do |name|
        define_method(name) do
          model = event_name.to_s.split("_").second.singularize.camelize.constantize
          @subject ||= model.find_by(id: params["id"])
        end
      end
    end
  end

  def perform(params)
    @params = params
    process_event
  end
end
Dir["app/events/**/*.rb"].each { |file| load file }

Wisper::ActiveRecord.extend_all unless ARGV.include? "db:migrate"
