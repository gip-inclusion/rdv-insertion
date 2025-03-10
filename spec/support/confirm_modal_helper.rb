module ConfirmModalHelper
  def confirm_modal
    find(".modal.show .btn-danger").click
  end
end
