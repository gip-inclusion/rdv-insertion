module UploadHelper
  shared_context "with file configuration" do
    let!(:file_configuration) do
      create(
        :file_configuration,
        title_column: "Civilité",
        first_name_column: "Prénom bénéficiaire",
        last_name_column: "Nom bénéficiaire",
        role_column: "Rôle",
        email_column: "Adresses Mails",
        phone_number_column: "N° Téléphones",
        birth_date_column: "Date de Naissance",
        birth_name_column: nil,
        address_first_field_column: nil,
        address_second_field_column: nil,
        address_third_field_column: "Adresse",
        address_fourth_field_column: "CP Ville",
        address_fifth_field_column: nil,
        affiliation_number_column: "N° Allocataire",
        france_travail_id_column: nil,
        nir_column: "NIR",
        department_internal_id_column: "id iodas ",
        rights_opening_date_column: nil,
        organisation_search_terms_column: "structure",
        referent_email_column: nil,
        tags_column: "Tags"
      )
    end
  end

  shared_context "with new file configuration" do
    let!(:file_configuration) do
      create(
        :file_configuration,
        title_column: "Civilité",
        first_name_column: "Prénom bénéficiaire",
        last_name_column: "Nom bénéficiaire",
        role_column: "Rôle",
        email_column: "Adresses Mails",
        phone_number_column: "N° Téléphones",
        birth_date_column: "Date de Naissance",
        birth_name_column: nil,
        address_first_field_column: nil,
        address_second_field_column: nil,
        address_third_field_column: "Adresse",
        address_fourth_field_column: "CP Ville",
        address_fifth_field_column: nil,
        affiliation_number_column: "N° Allocataire",
        france_travail_id_column: nil,
        nir_column: "NIR",
        department_internal_id_column: "id iodas ",
        rights_opening_date_column: nil,
        organisation_search_terms_column: "structure",
        referent_email_column: "référents",
        tags_column: "Tags"
      )
    end
  end
end
