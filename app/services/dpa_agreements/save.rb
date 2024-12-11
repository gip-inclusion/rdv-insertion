module DpaAgreements
  class Save < BaseService

    def initialize(dpa_accepted:, agent:, organisation:)
      @dpa_accepted = dpa_accepted
      @agent = agent
      @organisation = organisation
    end

    def call
      ensure_dpa_is_accepted
      DpaAgreement.create!(agent: @agent, organisation: @organisation)
    end

    private

    def ensure_dpa_is_accepted
      return if @dpa_accepted

      fail!("Vous devez accepter le DPA")
    end
  end
end
