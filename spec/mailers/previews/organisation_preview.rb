# Preview all emails at http://localhost:8000/rails/mailers/organisation
class OrganisationPreview < ActionMailer::Preview
  def applicant_added
    applicant = Applicant.last
    organisation = applicant.organisations.last
    OrganisationMailer.applicant_added(
      to: "someorg@gouv.fr",
      reply_to: "someagent@gouv.fr",
      subject: "[RDV-Insertion] Un allocataire a été ajouté à votre organisation",
      content: "Le bénéficiaire a #{applicant} été ajouté à votre organisation #{organisation.name}.\n"\
               "Vous pouvez consulter son profil à l'adresse suivante :\n"\
               "#{Rails.application.routes.url_helpers
                       .organisation_applicant_url(
                         id: applicant.id, organisation_id: organisation.id, host: ENV['HOST']
                       )}",
      applicant_attachements: []
    )
  end
end
