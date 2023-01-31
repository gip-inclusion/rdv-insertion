module Templating
  class MotifCategoriesWordings
    # PORO used to access the parameters defined in 'config/templates/motif_categories_wordings.yml
    # For example you access the rdv title for the rsa orientation category by calling:
    # Templating::MotifCategoriesWordings.rsa_orientation.rdv_title
    class << self
      def categories
        @categories ||= load_file["categories"]
      end

      private

      def load_file
        Psych.load_file(file_path)
      end

      def file_path
        Rails.root.join("config/templates/motif_categories_wordings.yml").to_s
      end
    end

    categories.each_key do |motif_category_short_name|
      self.class.define_method(motif_category_short_name) do
        OpenStruct.new(categories[motif_category_short_name.to_s])
      end
    end
  end
end
