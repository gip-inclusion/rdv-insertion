import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  setLoading() {
    this.element.innerHTML = "<div class='spinner-border spinner-border-sm text-center' role='status'></div>"
  }

  async edit() {
    const nonEditableAttributes = ["post_code"];
    const attribute = this.element.dataset.userRowAttribute;
    if (nonEditableAttributes.includes(attribute)) {
      return;
    }

    const { userListUploadId, userRowId, userRowAttribute } = this.element.dataset;

    const response = await fetch(`/user_list_uploads/${userListUploadId}/user_rows/${userRowId}/user_row_cells/edit?attribute=${userRowAttribute}`);
    const html = await response.text();
    if (response.ok) {
      window.Turbo.renderStreamMessage(html);

      // We're removing the padding on the parent element to ensure
      // that the input takes the whole space available.
      // Padding is automatically removed when frame re-renders
      this.element.style.padding = "0px"
      this.#focusNewlyAddedInput()
    }
  }

  #focusNewlyAddedInput() {
    // Ensure input has rendered
    setTimeout(() => {
      const input = this.element.querySelector("input[type=\"text\"], select")
      input.focus()

      if (input.type === "text") {
        // Move cursor to the end
        input.setSelectionRange(input.value.length, input.value.length);
        // Make sure we're seeing where the cursor is
        input.scrollLeft = input.scrollWidth;
      }
    }, 50)
  }
}
