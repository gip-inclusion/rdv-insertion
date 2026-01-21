module BeforeActionOverride
  extend ActiveSupport::Concern

  # This override enables before_action to take a `for` option that enables a filter
  # to be run for the controller actions passed as arguments but NOT EXCLUSIVELY
  # (which is not the case for `if` or `only` filters).
  # To do so it appends the name of the action on the filters. For example,
  # `set_organisations, for: :index` would produce `set_organisations_for_index, only: :index`.
  # Since the new filters (set_organisations_index in the example) are not instance methods on the controller,
  # we have to use method_missing hook to call the matching method.

  class_methods do
    def before_action(*names, &)
      names_dup = names.dup
      opts = names_dup.extract_options!
      if opts[:for].present?
        actions = Array(opts.delete(:for))
        new_names_by_action = actions.index_with do |action|
          action_opts = opts.dup
          action_opts[:only] ||= []
          action_opts[:only] << action
          names_dup.map do |name|
            :"#{name}_for_#{action}"
          end.push(action_opts)
        end
        new_names_by_action.each_value do |new_names|
          super(*new_names, &)
        end
      else
        super
      end
    end
  end

  def method_missing(method_name, *)
    return super unless method_name.to_s.end_with?("for_#{action_name}")

    splitted_method_name = method_name.to_s.split("_")
    matching_method = splitted_method_name[0...splitted_method_name.index("for")]
                      .join("_").to_sym

    if respond_to?(matching_method, true)
      send(matching_method)
    else
      super(matching_method, *)
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.end_with?("for_#{action_name}") || super
  end
end
