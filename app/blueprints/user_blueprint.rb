class UserBlueprint < ApplicationBlueprint
  FIELD_NAMES = [
    :uid, :affiliation_number, :role, :created_at, :department_internal_id,
    :first_name, :last_name, :title, :address, :phone_number, :email, :birth_date, :rights_opening_date,
    :birth_name, :rdv_solidarites_user_id, :nir, :carnet_de_bord_carnet_id, :france_travail_id
  ].freeze

  identifier :id

  FIELD_NAMES.each do |field_name|
    field field_name, if: lambda { |attribute_name, user, options|
                            if options[:organisation_type]
                              UserPolicy.show_user_attribute_for_organisation_type?(
                                attribute_name:, organisation_type: options[:organisation_type]
                              )
                            else
                              UserPolicy.show_user_attribute?(user:, attribute_name:)
                            end
                          }
  end

  view :with_referents do
    association :referents, blueprint: AgentBlueprint
  end

  view :extended do
    association :organisations, blueprint: OrganisationBlueprint
    association :referents, blueprint: AgentBlueprint
    association :archives, blueprint: ArchiveBlueprint
    association :address_geocoding, blueprint: AddressGeocodingBlueprint

    policy_scoped_association :invitations, blueprint: InvitationBlueprint
    policy_scoped_association :follow_ups, blueprint: FollowUpBlueprint
    policy_scoped_association :tags, blueprint: TagBlueprint
  end
end
