class Templating::MotifCategoriesSettings
  # PORO used to access the settings defined in 'config/templates/applicant_messages.yml
  # For example you access the rdv title for the rsa orientation category by calling:
  # Templating::MotifCategoriesSettings.rsa_orientation.rdv_title
  class TemplatingError < StandardError; end

  class << self
    Motif.categories.each_key do |motif_category|
      define_method(motif_category) do
        MotifCategorySettings.new(motif_category, categories[motif_category.to_s])
      end
    end

    def categories
      @categories ||= load_file["categories"]
    end

    def all_settings
      @all_settings ||= categories.values.flat_map(&:keys).uniq
    end

    private

    def load_file
      Psych.load_file(file_path)
    end

    def file_path
      Rails.root.join("config/templates/motif_categories_settings.yml").to_s
    end
  end

  class MotifCategorySettings
    def initialize(motif_category, attributes)
      @motif_category = motif_category
      @attributes = attributes
      Templating::MotifCategoriesSettings.all_settings.each do |attribute|
        define_singleton_method(attribute) { @attributes[attribute] }
      end
    end
  end
end
