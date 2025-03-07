module ConfirmModalHelper
  def confirm_modal(custom: false, title: nil, action: nil, content: nil)
    id = "modal-#{SecureRandom.uuid}"
    rendered_modal_content = render("common/confirm_modal", id:, title:, action:, custom:) { content }

    content_for(:confirm_modal) do
      rendered_modal_content
    end

    id
  end
end
