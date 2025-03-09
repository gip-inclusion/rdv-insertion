module ConfirmModalHelper
  def confirm_modal
    find(".modal.show .btn-danger", wait: 1).click
  end
end
