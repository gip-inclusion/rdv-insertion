import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  setLoading() {
    this.element.innerHTML = "<div class='spinner-border spinner-border-sm text-center' role='status'></div>"
  }

  async edit() {
    const { userListUploadId, userRowUid, userRowAttribute } = this.element.dataset;

    const response = await fetch(`/user_list_uploads/${userListUploadId}/user_rows/${userRowUid}/user_row_cells/edit?attribute=${userRowAttribute}`);
    const html = await response.text();
    if (response.ok) {
      window.Turbo.renderStreamMessage(html);
    }
  }
}
