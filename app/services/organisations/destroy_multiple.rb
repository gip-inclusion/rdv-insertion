# This class is intented to be used manually via a console
module Organisations
  class DestroyMultiple < BaseService
    # rubocop:disable Rails/Output
    def initialize(organisation_ids:, confirm: true)
      @organisation_ids = organisation_ids
      @confirm = confirm
    end

    def call
      @organisation_ids.each do |organisation_id|
        organisation = Organisation.find_by(id: organisation_id)

        if organisation.nil?
          p "Organisation with id #{organisation_id} not found"
          next
        end

        Organisations::DestroyJob.perform_async(organisation.id) if confirmed?(organisation)
      end
    end

    private

    def confirmed?(organisation)
      return true unless @confirm

      display_organisation_info(organisation)

      puts "Are you sure you want to destroy this organisation? (y/n)"
      $stdin.gets.chomp == "y"
    end

    def display_organisation_info(organisation)
      # Setting variables here to avoid having query logs in between the p calls
      users_count = organisation.users.count
      rdvs_count = organisation.rdvs.count
      any_rdvs = organisation.rdvs.any?
      last_rdv_created_at = organisation.rdvs.latest.created_at if any_rdvs
      organisation_exists = organisation_exists_in_rdv_solidarites?(organisation)

      puts "Destroying organisation: #{organisation.name} (id: #{organisation.id})"
      puts "Number of users : #{users_count}"
      puts "Number of rdvs : #{rdvs_count}"
      puts "Last rdv created : #{last_rdv_created_at}" if any_rdvs
      puts "⚠️ This organisation is still present in RDV-Solidarités" if organisation_exists
    end

    def organisation_exists_in_rdv_solidarites?(organisation)
      with_faked_agent_auth(organisation) do
        RdvSolidaritesApi::RetrieveOrganisation
          .call(rdv_solidarites_organisation_id: organisation.rdv_solidarites_organisation_id)
      end
    end

    def with_faked_agent_auth(organisation)
      return yield if Current.agent.present?

      Current.agent = organisation.agents.first
      result = yield
      Current.agent = nil

      result
    end
    # rubocop:enable Rails/Output
  end
end
