module HasAttachedImage
  extend ActiveSupport::Concern

  PUBLIC_STORAGE_SERVICE = :scaleway_public

  class_methods do
    # rubocop:disable Naming/PredicatePrefix
    def has_attached_image(
      name, max_size: 2.megabytes, formats: %w[PNG JPG], mime_types: ["image/png", "image/jpeg"],
      publicly_accessible: false
    )
      setup_attachment(name, publicly_accessible:)
      setup_validations(name, max_size:, formats:, mime_types:)
      setup_remover(name)
    end
    # rubocop:enable Naming/PredicatePrefix

    private

    def setup_attachment(name, publicly_accessible:)
      service = PUBLIC_STORAGE_SERVICE if publicly_accessible && Rails.env.production?
      has_one_attached name, service:
    end

    def setup_validations(name, max_size:, formats:, mime_types:)
      validates name, max_size:, accepted_formats: { formats:, mime_types: }
    end

    def setup_remover(name)
      remover_attr = :"remove_#{name}"
      attr_accessor remover_attr

      after_save -> { purge_attached_image(name) if send(remover_attr) == "true" }
    end
  end

  private

  def purge_attached_image(name)
    image = send(name)
    image.purge_later if image.attached?
  end
end
