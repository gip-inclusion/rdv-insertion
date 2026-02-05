module UserListUpload::UserRow::Selectable
  def assign_default_selection
    if user_list_upload.handle_invitation_only?
      self.selected_for_invitation = invitable?
    else
      self.selected_for_user_save = auto_selectable?
    end
  end

  private

  def should_auto_select_for_user_save?
    !selected_for_user_save? &&
      editable_attribute_changed? &&
      !being_deselected_in_same_transaction?
  end

  def auto_select_for_user_save
    self.selected_for_user_save = auto_selectable?
  end

  def being_deselected_in_same_transaction?
    selected_for_user_save_changed? && selected_for_user_save_was == true
  end

  def auto_selectable?
    user_valid? && !archived? && !matching_user_follow_up_closed?
  end
end
