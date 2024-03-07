module SimpleFormEncryptedAttributesExtension
  private

  def find_attribute_column(attribute_name)
    if @object.respond_to?(:type_for_attribute) && @object.has_attribute?(attribute_name)
      @object.type_for_attribute(attribute_name.to_s)
      detected_type = @object.type_for_attribute(attribute_name.to_s)

      # Some attributes like ActiveRecord::Encryption::EncryptedAttribute are detected
      # as different type, in that case we need to use the original type
      detected_type.respond_to?(:cast_type) ? detected_type.cast_type : detected_type
    elsif @object.respond_to?(:column_for_attribute) && @object.has_attribute?(attribute_name)
      @object.column_for_attribute(attribute_name)
    end
  end
end

SimpleForm::FormBuilder.prepend(SimpleFormEncryptedAttributesExtension)
