module User::Tags
  extend ActiveSupport::Concern

  included do
    has_many :tag_users, dependent: :destroy
    has_many :tags, through: :tag_users
  end

  def tags_to_add=(tags_attributes)
    tag_values = tags_attributes.pluck(:value)
    tag_values.each do |tag_value|
      next if tag_already_assigned?(tag_value)

      next unless (tag = find_tag_in_organisations(tag_value))

      tag_users.build(tag: tag)
    end
  end

  def tag_already_assigned?(tag_value)
    tag_value.in?(tags.pluck(:value))
  end

  private

  def find_tag_in_organisations(tag_value)
    Tag.joins(:tag_organisations)
       .where(value: tag_value, tag_organisations: { organisation_id: organisation_ids })
       .first
  end
end
