module Orientations
  class Save < BaseService
    def initialize(orientation:, should_override_overlap: false)
      @orientation = orientation
      @should_override_overlap = should_override_overlap
    end

    def call
      ActiveRecord::Base.transaction do
        validate_starts_at_presence
        fill_current_orientation_ends_at if @orientation.ends_at.nil? && posterior_orientations.any?
        add_user_to_organisation unless @orientation.user.belongs_to_org?(@orientation.organisation_id)
        save_record!(@orientation)
        validate_or_override_orientation_overlap
      end
    end

    private

    def add_user_to_organisation
      fail!("Une organisation doit être renseignée") if @orientation.organisation.nil?

      call_service!(
        Users::AddToOrganisations,
        user: @orientation.user,
        organisations: [@orientation.organisation]
      )
    end

    def other_user_orientations
      @other_user_orientations ||= @orientation.user.orientations.reject do |orientation|
        orientation.id == @orientation.id
      end
    end

    def previous_orientation_without_end_date
      @previous_orientation_without_end_date ||= other_user_orientations.find do |o|
        o.ends_at.nil? && o.starts_at < @orientation.starts_at
      end
    end

    def posterior_orientations
      @posterior_orientations ||= other_user_orientations.select do |o|
        o.starts_at > @orientation.starts_at
      end
    end

    def fill_current_orientation_ends_at
      @orientation.ends_at = posterior_orientations.min_by(&:starts_at).starts_at
    end

    # We want to validate this before saving the record.
    # We cannot launch the AR validation before assigning ends_at values
    def validate_starts_at_presence
      fail!("Une date de début doit être indiquée") unless @orientation.starts_at?
    end

    def validate_or_override_orientation_overlap
      if @should_override_overlap
        overlapping_orientations.first.update!(ends_at: @orientation.starts_at - 1.day)
      else
        validate_no_orientations_overlap
      end
    end

    def overlapping_orientations
      @overlapping_orientations ||= @orientation.user.orientations.overlapping(@orientation)
    end

    def validate_no_orientations_overlap
      return if overlapping_orientations.empty?

      if overlapping_orientations.size > 1
        return fail!(
          "Cette orientation chevauche plusieurs autres orientations, veuillez adapter les dates de début et de fin"
        )
      end

      if overrideable_overlap?
        result.errors << { overrideable_overlap: true, overlapping_orientation: overlapping_orientations.first }
        return fail!
      end

      fail!("Cette orientation chevauche une autre orientation qui ne peut être raccourcie automatiquement,
                    veuillez modifier l'orientation en question ou changer les dates renseignées ci-dessous")
    end

    def overrideable_overlap?
      starts_at_delta = (@orientation.starts_at - overlapping_orientations.first.starts_at).to_i
      starts_at_delta > Orientation::MINIMUM_DURATION_IN_DAYS + 1
    end
  end
end
