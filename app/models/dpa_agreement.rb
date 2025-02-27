class DpaAgreement < ApplicationRecord
  belongs_to :organisation
  belongs_to :agent, optional: true

  validates :organisation, uniqueness: true
  validates :agent, presence: true, on: :create

  before_save :set_identity

  def set_identity
    return if agent.nil?

    self.agent_full_name = agent.to_s
    self.agent_email = agent.email
  end
end
