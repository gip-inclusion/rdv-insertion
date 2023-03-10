FactoryBot.define do
  factory :file_configuration do
    sequence(:sheet_name) { |n| "LISTE DEMANDEURS_#{n}" }
    column_names do
      { optional: {},
        required: {
          city: "Commune",
          role: "Rôle",
          email: "Adresses Mails",
          title: "Civilité",
          address: "Complément lieu",
          last_name: "Nom bénéficiaire",
          birth_date: "Date de naissance",
          first_name: "Prénom bénéficiaire",
          postal_code: "CP",
          street_type: "Complement Destinataire",
          phone_number: "N° Téléphones",
          street_number: "Adresse",
          referent_email: "Référent",
          affiliation_number: "N° Allocataire"
        } }
    end
  end
end
