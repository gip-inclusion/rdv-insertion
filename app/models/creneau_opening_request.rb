class CreneauOpeningRequest < ApplicationRecord
  belongs_to :user_list_upload
  belongs_to :recipient_agent, class_name: "Agent"

  validates :uuid, uniqueness: true, allow_nil: true
  # A voir si on garde link en db ou si on le calcule quand on en a besoin ?
  validates :link, presence: true
  validates :users_to_invite_count, :available_creneaux_count,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  delegate :motif_category, :motif_category_name, :category_configuration, to: :user_list_upload

  def sender_agent = user_list_upload.agent
  def missing_creneaux_count = users_to_invite_count - available_creneaux_count

  before_create :assign_uuid
  after_commit :enqueue_send_email_job, on: :create

  private

  def assign_uuid
    self.uuid = generate_uuid
  end

  def generate_uuid
    loop do
      uuid = SecureRandom.send(:choose, [*"A".."Z", *"0".."9"], 8)
      break uuid unless self.class.find_by(uuid: uuid)
    end
  end

  def enqueue_send_email_job
    CreneauOpeningRequests::SendEmailJob.perform_later(id)
  end
end
