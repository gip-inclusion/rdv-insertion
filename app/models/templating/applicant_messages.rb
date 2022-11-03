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
    end

    def invitation_purpose
      fetch("invitation_purpose")
    end

    def rdv_title
      fetch("rdv_title")
    end

    def rdv_title_by_phone
      fetch("rdv_title_by_phone")
    end

    def display_mandatory_warning
      fetch("display_mandatory_warning")
    end

    def display_punishable_warning
      fetch("display_punishable_warning")
    end

    private

    def fetch(attribute_name)
      attribute = @attributes[attribute_name]
      raise_for_missing_attribute(attribute_name) if attribute.nil?
      attribute
    end

    def raise_for_missing_attribute(attribute)
      raise TemplatingError, "#{attribute} not found for category #{@motif_category}"
    end
  end
end
