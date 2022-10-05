class MessagesBoilerplates
  class << self
    def categories
      @categories ||= JSON.parse(load_file["categories"].to_json, object_class: OpenStruct)
    end

    private

    def load_file
      Psych.load_file(file_path)
    end

    def file_path
      Rails.root.join('config/settings/messages_boilerplates.yml').to_s
    end
  end
end
