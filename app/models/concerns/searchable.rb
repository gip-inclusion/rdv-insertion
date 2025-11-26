module Searchable
  extend ActiveSupport::Concern

  include PgSearch::Model

  included do
    pg_search_scope(
      :search_by_text,
      using: { tsearch: { prefix: true } },
      against: self::SEARCH_ATTRIBUTES,
      ignoring: :accents
    )
  end
end
