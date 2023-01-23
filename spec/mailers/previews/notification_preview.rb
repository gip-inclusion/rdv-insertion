# Preview all emails at http://localhost:8000/rails/mailers/notifications
# rubocop:disable Metrics/ClassLength
class NotificationPreview < ActionMailer::Preview
  ###### rsa_orientation ######
  ### participation_created ###
  def rsa_orientation_presential_participation_created
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_orientation")
      .presential_participation_created
  end

  def rsa_orientation_by_phone_participation_created
    NotificationMailer
      .with(
        rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_orientation"
      )
      .by_phone_participation_created
  end

  ### participation_updated ###
  def rsa_orientation_presential_participation_updated
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_orientation")
      .presential_participation_updated
  end

  def rsa_orientation_by_phone_participation_updated
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_orientation")
      .by_phone_participation_updated
  end

  ### rdv_cancelled ###
  def rsa_orientation_rdv_cancelled
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_orientation")
      .rdv_cancelled
  end

  ###### rsa_accompagnement ######
  ### participation_created ###
  def rsa_accompagnement_presential_participation_created
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_accompagnement")
      .presential_participation_created
  end

  def rsa_accompagnement_by_phone_participation_created
    NotificationMailer
      .with(
        rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_accompagnement"
      )
      .by_phone_participation_created
  end

  ### participation_updated ###
  def rsa_accompagnement_presential_participation_updated
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_accompagnement")
      .presential_participation_updated
  end

  def rsa_accompagnement_by_phone_participation_updated
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_accompagnement")
      .by_phone_participation_updated
  end

  ### rdv_cancelled ###
  def rsa_accompagnement_rdv_cancelled
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_accompagnement")
      .rdv_cancelled
  end

  ###### rsa_accompagnement_social ######
  ### participation_created ###
  def rsa_accompagnement_social_presential_participation_created
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines,
            motif_category: "rsa_accompagnement_social")
      .presential_participation_created
  end

  def rsa_accompagnement_social_by_phone_participation_created
    NotificationMailer
      .with(
        rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_accompagnement_social"
      )
      .by_phone_participation_created
  end

  ### participation_updated ###
  def rsa_accompagnement_social_presential_participation_updated
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines,
            motif_category: "rsa_accompagnement_social")
      .presential_participation_updated
  end

  def rsa_accompagnement_social_by_phone_participation_updated
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines,
            motif_category: "rsa_accompagnement_social")
      .by_phone_participation_updated
  end

  ### rdv_cancelled ###
  def rsa_accompagnement_social_rdv_cancelled
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines,
            motif_category: "rsa_accompagnement_social")
      .rdv_cancelled
  end

  ###### rsa_accompagnement_sociopro ######
  ### participation_created ###
  def rsa_accompagnement_sociopro_presential_participation_created
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines,
            motif_category: "rsa_accompagnement_sociopro")
      .presential_participation_created
  end

  def rsa_accompagnement_sociopro_by_phone_participation_created
    NotificationMailer
      .with(
        rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_accompagnement_sociopro"
      )
      .by_phone_participation_created
  end

  ### participation_updated ###
  def rsa_accompagnement_sociopro_presential_participation_updated
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines,
            motif_category: "rsa_accompagnement_sociopro")
      .presential_participation_updated
  end

  def rsa_accompagnement_sociopro_by_phone_participation_updated
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines,
            motif_category: "rsa_accompagnement_sociopro")
      .by_phone_participation_updated
  end

  ### rdv_cancelled ###
  def rsa_accompagnement_sociopro_rdv_cancelled
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines,
            motif_category: "rsa_accompagnement_sociopro")
      .rdv_cancelled
  end

  ###### rsa_cer_signature ######
  ### participation_created ###
  def rsa_cer_signature_presential_participation_created
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_cer_signature")
      .presential_participation_created
  end

  def rsa_cer_signature_by_phone_participation_created
    NotificationMailer
      .with(
        rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_cer_signature"
      )
      .by_phone_participation_created
  end

  ### participation_updated ###
  def rsa_cer_signature_presential_participation_updated
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_cer_signature")
      .presential_participation_updated
  end

  def rsa_cer_signature_by_phone_participation_updated
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_cer_signature")
      .by_phone_participation_updated
  end

  ### rdv_cancelled ###
  def rsa_cer_signature_rdv_cancelled
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_cer_signature")
      .rdv_cancelled
  end

  ###### rsa_follow_up ######
  ### participation_created ###
  def rsa_follow_up_presential_participation_created
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_follow_up")
      .presential_participation_created
  end

  def rsa_follow_up_by_phone_participation_created
    NotificationMailer
      .with(
        rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_follow_up"
      )
      .by_phone_participation_created
  end

  ### participation_updated ###
  def rsa_follow_up_presential_participation_updated
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_follow_up")
      .presential_participation_updated
  end

  def rsa_follow_up_by_phone_participation_updated
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_follow_up")
      .by_phone_participation_updated
  end

  ### rdv_cancelled ###
  def rsa_follow_up_rdv_cancelled
    NotificationMailer
      .with(rdv: rdv, applicant: applicant, signature_lines: signature_lines, motif_category: "rsa_follow_up")
      .rdv_cancelled
  end

  private

  def signature_lines
    MessagesConfiguration.last.signature_lines
  end

  def rdv
    Rdv.with_lieu.last
  end

  def department
    applicant.department
  end

  def applicant
    Applicant.where.not(phone_number: nil).last
  end
end
# rubocop:enable Metrics/ClassLength
