module ConfirmModalHelper
  def confirm_modal
    find(".modal .btn-danger", wait: 10).click
  end
end
