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
        street_number_column: nil,
        street_type_column: nil,
        address_column: "Adresse",
        postal_code_column: "CP Ville",
        city_column: nil,
        affiliation_number_column: "N° Allocataire",
        pole_emploi_id_column: nil,
        nir_column: "NIR",
        department_internal_id_column: "id iodas ",
        rights_opening_date_column: nil,
        organisation_search_terms_column: "structure",
        referent_email_column: nil
      )
    end
  end
end
