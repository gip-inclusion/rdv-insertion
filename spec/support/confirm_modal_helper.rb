module ConfirmModalHelper
  def confirm_modal
    within(".modal.show") do
      find(".btn-danger").click
    end
  end
end
