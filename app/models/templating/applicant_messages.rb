class Templating::ApplicantMessages
  # PORO used to access the settings defined in 'config/templates/applicant_messages.yml
  # For example you access the rdv title for the rsa orientation category by calling:
  # Templating::ApplicantMessages.rsa_orientation.rdv_title
  class TemplatingError < StandardError; end

  class << self
    Motif.categories.each_key do |motif_category|
      define_method(motif_category) do
        MotifCategory.new(motif_category, categories[motif_category.to_s])
      end
    end

    def categories
      @categories ||= load_file["categories"]
    end

    private

    def load_file
      Psych.load_file(file_path)
    end

    def file_path
      Rails.root.join('config/templates/applicant_messages.yml').to_s
    end
  end

  class MotifCategory
    def initialize(motif_category, attributes)
      @motif_category = motif_category
      @attributes = attributes
      @attributes.each_key do |attribute|
        define_singleton_method(attribute) { @attributes[attribute] }
      end
    end
  end
end
