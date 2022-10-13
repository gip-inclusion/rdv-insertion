class Settings::MotifCategory
  # PORO used to access the settings defined in 'config/settings/motif_category.yml
  # For example you access the rdv title for the rsa orientation category by calling:
  # Settings::MotifCategory.rsa_orientation.rdv_title

  class << self
    Motif.categories.each_key do |motif_category|
      define_method(motif_category) do
        categories.send(:"#{motif_category}")
      end
    end

    def categories
      @categories ||= JSON.parse(load_file.to_json, object_class: OpenStruct)
    end

    private

    def load_file
      Psych.load_file(file_path)
    end

    def file_path
      Rails.root.join('config/settings/motif_category.yml').to_s
    end
  end
end
