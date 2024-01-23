module User::Referents
  extend ActiveSupport::Concern

  included do
    has_many :referent_assignations, dependent: :destroy
    has_many :referents, through: :referent_assignations, source: :agent
  end

  def referents_to_add=(referents_attributes)
    referents_emails = referents_attributes.pluck(:email)
    referents_emails.each do |referent_email|
      next if referent_already_assigned?(referent_email)

      next unless (referent = Agent.find_by(email: referent_email))

      referent_assignations.build(agent: referent)
    end
  end

  def referent_already_assigned?(referent_email)
    referent_email.in?(referents.pluck(:email))
  end
end
