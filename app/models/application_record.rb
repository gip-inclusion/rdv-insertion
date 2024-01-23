class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include Serializable
end
