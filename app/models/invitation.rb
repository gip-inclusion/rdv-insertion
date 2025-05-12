class Invitation < ApplicationRecord
  NUMBER_OF_DAYS_BEFORE_REMINDER = 3

  include HasCurrentCategoryConfiguration
  include Templatable
  include Sendable
  include WebhookDeliverable
  include Deliverable
  include HasSmsProvider

  belongs_to :user
  belongs_to :department
  belongs_to :follow_up

  has_and_belongs_to_many :organisations

  has_many :category_configurations, through: :organisations
  has_many :webhook_endpoints, through: :organisations
  has_many :invitation_attempts, class_name: "UserListUpload::InvitationAttempt", dependent: :destroy

  attr_accessor :content

  validates :help_phone_number, :rdv_solidarites_token, :organisations, :link, presence: true
  validates :uuid, uniqueness: true, allow_nil: true

  delegate :motif_category, :motif_category_name, :motif_category_id, to: :follow_up
  delegate :model, to: :template, prefix: true
  delegate :post_code, to: :user, prefix: true, allow_nil: true

  enum :format, { sms: "sms", email: "email", postal: "postal" }, prefix: true
  enum :trigger, { manual: "manual", reminder: "reminder", periodic: "periodic" }

  before_create :assign_uuid
  after_commit :set_follow_up_status

  scope :valid, -> { where("expires_at > ?", Time.zone.now).or(never_expire) }
  scope :expired, -> { where(expires_at: ..Time.zone.now) }
  scope :expireable, -> { where.not(expires_at: nil) }
  scope :never_expire, -> { where(expires_at: nil) }

  def send_to_user
    case self.format
    when "sms"
      Invitations::SendSms.call(invitation: self)
    when "email"
      Invitations::SendEmail.call(invitation: self)
    when "postal"
      Invitations::GenerateLetter.call(invitation: self)
    end
  end

  def help_phone_number_formatted
    Phonelib.parse(help_phone_number).national
  end

  def messages_configuration
    organisations.map(&:messages_configuration).compact.first
  end

  def number_of_days_before_expiration
    return if never_expires?

    if expired?
      0
    else
      (expires_at.to_date - Time.zone.now.to_date).to_i
    end
  end

  def never_expires? = expires_at.nil?

  def expireable? = expires_at.present?

  def expired?
    expireable? && expires_at <= Time.zone.now
  end

  def expire!
    return true if expired?

    update!(expires_at: Time.zone.now)
  end

  def sent_before?(date)
    created_at <= date
  end

  def sent_after?(date)
    created_at >= date
  end

  def link_params
    uri = URI.parse(link)
    Rack::Utils.parse_nested_query(uri.query)
  end

  def rdv_solidarites_public_url(with_protocol: true)
    url = "#{ENV['RDV_SOLIDARITES_URL']}/i/r/#{uuid}"

    with_protocol ? url : url.gsub("https://", "").gsub("http://", "").gsub("www.", "")
  end

  def qr_code
    RQRCode::QRCode.new(rdv_solidarites_public_url).as_png
  end

  def referent_ids = link_params["referent_ids"]

  def referents
    return Agent.none if referent_ids.blank?

    Agent.where(rdv_solidarites_agent_id: referent_ids)
  end

  def referent_emails = referents.pluck(:email)

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

  def set_follow_up_status
    RefreshFollowUpStatusesJob.perform_later(follow_up_id)
  end
end
