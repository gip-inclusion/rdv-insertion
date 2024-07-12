module Archives
  class CreateMany < BaseService
    def initialize(user_id:, archiving_reason:, organisation_ids:)
      @user_id = user_id
      @archiving_reason = archiving_reason
      @organisation_ids = organisation_ids
    end

    def call
      Archive.transaction do
        create_archives
      end
    end

    private

    def create_archives
      @organisation_ids.each do |organisation_id|
        create_archive(organisation_id)
      end
    end

    def create_archive(organisation_id)
      archive = Archive.new(user_id: @user_id, organisation_id: organisation_id, archiving_reason: @archiving_reason)
      save_record!(archive)
    end
  end
end
