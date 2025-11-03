module Serializable
  def as_json(opts = {})
    if blueprint_class
      blueprint_class.render_as_json(self, default_blueprint_view_opts.merge(opts))
    else
      super
    end
  end

  private

  def blueprint_class
    "#{self.class}Blueprint".safe_constantize
  end

  def default_blueprint_view_opts
    blueprint_class.view?(:extended) ? { view: :extended } : {}
  end
end
