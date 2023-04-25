class AddWarningsTextsToTemplates < ActiveRecord::Migration[7.0]
  def up
    # We do this first because we added a validation on display_mandatory_warning
    Template.find_each do |template|
      if template.model == "phone_platform"
        template.display_mandatory_warning = true
      elsif template.display_mandatory_warning.nil?
        template.display_mandatory_warning = false
      end
      template.save!(validate: false)
    end

    add_column :templates, :punishable_warning, :text, null: false, default: ""

    Template.find_each do |template|
      template.punishable_warning = if template.display_punishable_warning?
                                      "votre RSA pourra être suspendu ou réduit"
                                    else
                                      false
                                    end
      template.save!
    end

    change_column_default :templates, :display_mandatory_warning, from: nil, to: false
    remove_column :templates, :display_punishable_warning, :boolean
  end

  def down
    add_column :templates, :display_punishable_warning, :boolean
    change_column_default :templates, :display_mandatory_warning, from: false, to: nil

    Template.find_each do |template|
      template.display_punishable_warning = template.punishable_warning.present?
      template.save!
    end

    remove_column :templates, :punishable_warning
  end
end
