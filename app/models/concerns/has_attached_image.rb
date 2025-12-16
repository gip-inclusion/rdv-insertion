module HasAttachedImage
  extend ActiveSupport::Concern

  class_methods do
    # rubocop:disable Naming/PredicateName
    def has_attached_image(
      name, max_size: 2.megabytes, formats: %w[PNG JPG], mime_types: ["image/png", "image/jpeg"]
    )
      has_one_attached name

      validates name, max_size:,
                      accepted_formats: { formats:, mime_types: }

      remover_attr = :"remove_#{name}"
      attr_accessor remover_attr

      after_save -> { purge_attached_image(name) if send(remover_attr) == "true" }
    end
  end
  # rubocop:enable Naming/PredicateName

  private

  def purge_attached_image(name)
    attachment = send(name)
    attachment.purge_later if attachment.attached?
  end
end
