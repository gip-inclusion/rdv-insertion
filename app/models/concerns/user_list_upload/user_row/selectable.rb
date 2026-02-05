module UserListUpload::UserRow::Selectable
  extend ActiveSupport::Concern

  included do
    before_save :auto_select_for_user_save, if: :should_auto_select_for_user_save?
  end

  def assign_default_selection
    if user_list_upload.handle_invitation_only?
      self.selected_for_invitation = invitable?
    else
      self.selected_for_user_save = user_saveable?
    end
  end

  private

  def should_auto_select_for_user_save?
    !selected_for_user_save? &&
      editable_attribute_changed? &&
      !being_deselected_in_same_transaction?
  end

  def auto_select_for_user_save
    self.selected_for_user_save = user_saveable?
  end

  def being_deselected_in_same_transaction?
    selected_for_user_save_changed? && selected_for_user_save_was == true
  end

  def editable_attribute_changed?
    (changed & self.class::EDITABLE_ATTRIBUTES.map(&:to_s)).any?
  end

  def user_saveable?
    user_valid? && !archived? && !matching_user_follow_up_closed?
  end
end
