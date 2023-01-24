class Templating::MotifCategoriesWordings
  # PORO used to access the parameters defined in 'config/templates/motif_categories_wordings.yml
  # For example you access the rdv title for the rsa orientation category by calling:
  # Templating::MotifCategoriesWordings.rsa_orientation.rdv_title
  class TemplatingError < StandardError; end

  class << self
    Motif.categories.each_key do |motif_category|
      define_method(motif_category) do
        MotifCategoryWordings.new(motif_category, categories[motif_category.to_s])
      end
    end

    def categories
      @categories ||= load_file["categories"]
    end

    def all_parameters
      @all_parameters ||= categories.values.flat_map(&:keys).uniq
    end

    private

    def load_file
      Psych.load_file(file_path)
    end

    def file_path
      Rails.root.join("config/templates/motif_categories_wordings.yml").to_s
    end
  end

  class MotifCategoryWordings
    def initialize(motif_category, attributes)
      @motif_category = motif_category
      @attributes = attributes
      Templating::MotifCategoriesWordings.all_parameters.each do |attribute|
        define_singleton_method(attribute) { @attributes[attribute] }
      end
    end
  end
end
