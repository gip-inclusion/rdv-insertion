class TemplatedErrorPresenter < ErrorPresenter
  attr_reader :template_name, :locals

  def initialize(message, template_name:, locals: {})
    super(message)
    @template_name = template_name
    @locals = locals
  end

  def to_partial_path
    "common/custom_errors/#{@template_name}"
  end
end
