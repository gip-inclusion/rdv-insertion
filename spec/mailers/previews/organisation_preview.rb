# Preview all emails at http://localhost:8000/rails/mailers/organisation
class OrganisationPreview < ActionMailer::Preview
  def user_added
    user = User.last
    organisation = user.organisations.last
    OrganisationMailer.user_added(
      to: "someorg@gouv.fr",
      reply_to: "someagent@gouv.fr",
      subject: "[RDV-Insertion] Un usager a été ajouté à votre organisation",
      content: "Le bénéficiaire a #{user} été ajouté à votre organisation #{organisation.name}.\n" \
               "Vous pouvez consulter son profil à l'adresse suivante :\n" \
               "#{Rails.application.routes.url_helpers
                       .organisation_user_url(
                         id: user.id, organisation_id: organisation.id, host: ENV['HOST']
                       )}",
      user_attachements: []
    )
  end
end
