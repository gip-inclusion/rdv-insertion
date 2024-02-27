module Serializable
  def as_json(...) = blueprint_class ? blueprint_class.render_as_json(self, blueprint_view_opts) : super

  private

  def blueprint_class
    "#{self.class}Blueprint".safe_constantize
  end

  def blueprint_view_opts
    {}
  end
end
