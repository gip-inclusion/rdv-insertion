module Serializable
  def as_json(opts = {})
    if blueprint_class
      blueprint_class.render_as_json(self, opts.merge(blueprint_view_opts))
    else
      super
    end
  end

  private

  def blueprint_class
    "#{self.class}Blueprint".safe_constantize
  end

  def blueprint_view_opts
    blueprint_class.view?(:extended) ? { view: :extended } : {}
  end
end
