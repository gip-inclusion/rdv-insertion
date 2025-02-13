import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  setLoading() {
    this.element.innerHTML = "<div class='spinner-border spinner-border-sm text-center' role='status'></div>"
  }

  async edit() {
    const { userListUploadId, userRowId, userRowAttribute } = this.element.dataset;

    const currentUrl = new URL(window.location.href);
    const queryString = currentUrl.searchParams.toString();
    const formattedQueryString = queryString ? `&${queryString}` : "";

    const response = await fetch(`/user_list_uploads/${userListUploadId}/user_rows/${userRowId}/user_row_cells/edit?attribute=${userRowAttribute}${formattedQueryString}`);
    const html = await response.text();
    if (response.ok) {
      window.Turbo.renderStreamMessage(html);
    }
  }
}
