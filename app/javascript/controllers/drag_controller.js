import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";

export default class extends Controller {
  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      onEnd: this.end.bind(this)
    });
  }

  end() {
    fetch(this.data.get("url"), {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content
      },
      body: JSON.stringify({
        configuration_ids_and_positions: this.sortable.toArray().map((id, index) => ({ id, position: index }))
      })
    });
  }
}
