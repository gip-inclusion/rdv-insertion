import { Controller } from "@hotwired/stimulus";
import DOMPurify from "dompurify";
import safeTippy from "../lib/safeTippy";

export default class extends Controller {
  showContent() {
    const { tooltipContent, placement } = this.element.dataset;

    // If a tooltip is already attached, just update its content.
    // Destroy + recreate would cause the new tippy to miss the ongoing hover.
    /* eslint-disable no-underscore-dangle */
    if (this.element._tippy) {
      this.element._tippy.setContent(DOMPurify.sanitize(tooltipContent));
      return;
    }
    /* eslint-enable no-underscore-dangle */

    safeTippy(this.element, {
      content: tooltipContent,
      allowHTML: true,
      showOnCreate: true,
      ...(placement ? { placement } : {}),
    });
  }
}
