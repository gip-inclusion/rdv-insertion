module Orientations
  class Save < BaseService
    def initialize(orientation:)
      @orientation = orientation
    end

    def call
      ActiveRecord::Base.transaction do
        validate_starts_at_presence
        update_previous_orientation_ends_at if previous_orientation_without_end_date.present?
        fill_current_orientation_ends_at if @orientation.ends_at.nil? && posterior_orientations.any?
        validate_no_orientations_overlap
        add_user_to_organisation if @orientation.user.organisation_ids.exclude?(@orientation.organisation)
        save_record!(@orientation)
      end
    end

    private

    def add_user_to_organisation
      @orientation.user.organisations << @orientation.organisation
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

    def update_previous_orientation_ends_at
      previous_orientation_without_end_date.ends_at = @orientation.starts_at
      return if previous_orientation_without_end_date.save

      fail!(
        "La date de fin n'a pas pu être mise automatiquement sur l'orientation précédente: " \
        "#{previous_orientation_without_end_date}"
      )
    end

    def fill_current_orientation_ends_at
      @orientation.ends_at = posterior_orientations.min_by(&:starts_at).starts_at
    end

    # We want to validate this before saving the record.
    # We cannot launch the AR validation before assigning ends_at values
    def validate_starts_at_presence
      fail!("une date de début doit être indiquée") unless @orientation.starts_at?
    end

    def validate_no_orientations_overlap
      return if other_user_orientations.none? do |other_orientation|
        other_orientation.time_range.to_a.intersect?(@orientation.time_range.to_a)
      end

      fail!("les dates se chevauchent avec une autre orientation")
    end
  end
end
