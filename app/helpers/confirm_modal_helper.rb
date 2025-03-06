module ConfirmModalHelper
  def confirm_modal(title: nil, action: nil, content: nil)
    id = "modal-#{SecureRandom.uuid}"
    content_for(:confirm_modal) do
      render("common/confirm_modal", id:, title:, action:) { content }
    end

    id
  end
end
