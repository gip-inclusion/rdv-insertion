module Archives
  class CreateMany < BaseService
    def initialize(user_id:, archiving_reason:, organisation_ids:)
      @user_id = user_id
      @archiving_reason = archiving_reason
      @organisation_ids = organisation_ids
    end

    def call
      create_archives
    end

    private

    def create_archives
      @organisation_ids.each do |organisation_id|
        create_archive(organisation_id)
      end
    end

    def create_archive(organisation_id)
      Archive.create(user_id: @user_id, organisation_id: organisation_id, archiving_reason: @archiving_reason)
    end
  end
end
