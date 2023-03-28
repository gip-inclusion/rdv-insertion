FactoryBot.define do
  factory :file_configuration do
    sequence(:sheet_name) { |n| "LISTE DEMANDEURS_#{n}" }
    city_column { "Commune" }
    role_column { "Rôle" }
    email_column { "Adresses Mails" }
    title_column { "Civilité" }
    address_column { "Complément lieu" }
    last_name_column { "Nom bénéficiaire" }
    birth_date_column { "Date de naissance" }
    first_name_column { "Prénom bénéficiaire" }
    postal_code_column { "CP" }
    street_type_column { "Complement Destinataire" }
    phone_number_column { "N° Téléphones" }
    street_number_column { "Adresse" }
    referent_email_column { "Référent" }
    affiliation_number_column { "N° Allocataire" }
    pole_emploi_id_column { "ID PE" }
    nir_column { "NIR" }
  end
end
