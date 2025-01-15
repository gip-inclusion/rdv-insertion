import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  async edit() {
    const { userListUploadId, userRowUid, userRowAttribute } = this.element.dataset;
    console.log(userListUploadId, userRowUid, userRowAttribute);

    const response = await fetch(`/user_list_uploads/${userListUploadId}/user_rows/${userRowUid}/user_row_cells/edit?attribute=${userRowAttribute}`);
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
