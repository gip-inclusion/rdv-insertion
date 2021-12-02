module SearchableConcern
  extend ActiveSupport::Concern

  include PgSearch::Model

  included do
    pg_search_scope(
      :search_by_text,
      using: { tsearch: { prefix: true } },
      against: [:first_name, :last_name, :affiliation_number, :email, :phone_number]
    )
  end
end
