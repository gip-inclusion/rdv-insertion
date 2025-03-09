module ConfirmModalHelper
  def confirm_modal
    expect(page).to have_css(".modal.show")
    within(".modal.show") do
      find(".btn-danger").click
    end
  end
end
