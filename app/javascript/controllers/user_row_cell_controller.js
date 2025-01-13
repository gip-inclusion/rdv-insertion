import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  async edit() {
    const { userListUploadId, userRowUid, attribute } = this.element.dataset;
    console.log(userListUploadId, userRowUid, attribute);

    const response = await fetch(`/user_list_uploads/${userListUploadId}/user_rows/${userRowUid}/user_row_cells/edit?attribute=${attribute}`);
    const html = await response.text();
    if (response.ok) {
      window.Turbo.renderStreamMessage(html);
    }
  }

  show() {
    this.showTarget.classList.remove("d-none");
    this.editTarget.classList.add("d-none");
  }
}
