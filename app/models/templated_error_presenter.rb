class TemplatedErrorPresenter
  attr_reader :message, :template_name, :locals

  def initialize(message:, template_name:, locals: {})
    @message = message
    @template_name = template_name
    @locals = locals
  end

  def to_s
    message
  end

  def partial_path
    "custom_errors/#{@template_name}"
  end

  def render(view_context)
    view_context.render(partial_path, **@locals)
  rescue ActionView::MissingTemplate, ActionView::Template::Error => e
    Sentry.capture_exception(e)
    # Fallback sur un message simple
    view_context.content_tag(:p, @message)
  end
end
