class ArrayInput < SimpleForm::Inputs::StringInput
  # SimpleForm do not deal with array columns natively ; we add here the option "as: :array" to manage it
  # See https://github.com/heartcombo/simple_form/wiki/Custom-inputs-examples
  def input(_wrapper_options)
    input_html_options[:type] ||= :text
    existing_values = object.public_send(attribute_name)
    existing_values.push(nil) if existing_values.blank?
    build_array_input(existing_values, attribute_name)
  end

  private

  def build_array_input(existing_values, attribute_name)
    template.content_tag(:div, class: "text-array", id: "#{object_name}_#{attribute_name}") do
      Array(existing_values).map.with_index do |array_el, index|
        template.concat build_row(array_el, object_name, attribute_name, index)
      end

      template.concat add_new_row_button
    end
  end

  def build_row(array_el, object_name, attribute_name, index)
    @builder.template.render(partial: "common/array_fields/input",
                             locals: { array_el: array_el, object_name: object_name,
                                       attribute_name: attribute_name, index: index })
  end

  def add_new_row_button
    @builder.template.render(partial: "common/array_fields/add_new_row_button")
  end
end
