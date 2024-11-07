module Orientations
  class Save < BaseService
    def initialize(orientation:, update_anterior_ends_at: false)
      @orientation = orientation
      @update_anterior_ends_at = update_anterior_ends_at
    end

    def call
      ActiveRecord::Base.transaction do
        validate_starts_at_presence
        fill_current_orientation_ends_at if @orientation.ends_at.nil? && posterior_orientations.any?
        add_user_to_organisation unless @orientation.user.belongs_to_org?(@orientation.organisation_id)
        save_record!(@orientation)
        shrink_or_ensure_no_overlapping
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
      @orientation.ends_at = posterior_orientations.min_by(&:starts_at).starts_at - 1.day
    end

    # We want to validate this before saving the record.
    # We cannot launch the AR validation before assigning ends_at values
    def validate_starts_at_presence
      fail!("Une date de début doit être indiquée") unless @orientation.starts_at?
    end

    def shrink_or_ensure_no_overlapping
      if shrinkeable_orientations.one? && non_shrinkable_overlapping_orientations.empty?
        if @update_anterior_ends_at
          shrinkeable_orientations.first.update!(ends_at: @orientation.starts_at - 1.day)
        else
          result.shrinkeable_orientation = shrinkeable_orientations.first
          return fail!
        end
      else
        validate_no_orientations_overlap
      end
    end

    def shrinkeable_orientations
      @shrinkeable_orientations ||= @orientation.user.orientations.shrinkeable_to_fit(@orientation)
    end

    def non_shrinkable_overlapping_orientations
      @non_shrinkable_overlapping_orientations ||= other_user_orientations.select do |other_orientation|
        other_orientation.time_range.to_a.intersect?(@orientation.time_range.to_a)
      end - shrinkeable_orientations
    end

    def validate_no_orientations_overlap
      return if non_shrinkable_overlapping_orientations.empty?

      fail!("Cette orientation chevauche une autre orientation qui ne peut être raccourcie automatiquement,
                    veuillez modifier l'orientation en question ou changer les dates renseignées ci-dessous")
    end
  end
end
