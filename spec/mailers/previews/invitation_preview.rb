# Preview all emails at http://localhost:8000/rails/mailers/invitation
class InvitationPreview < ActionMailer::Preview
  MotifCategory.find_each do |motif_category|
    invitation = Invitation.sent.format_email.last
    applicant = invitation.applicant
    rdv_context = RdvContext.new(motif_category: motif_category, applicant: applicant)
    invitation.rdv_context = rdv_context

    define_method motif_category.short_name do
      InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                      .send("#{motif_category.template_model}_invitation")
    end

    next unless motif_category.rdvs_mandatory?

    define_method "#{motif_category.short_name}_rappel" do
      InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                      .send("#{motif_category.template_model}_invitation_reminder")
    end
  end
end
