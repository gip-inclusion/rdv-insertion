import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";

export default class extends Controller {
  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      onEnd: this.end.bind(this)
    });
  }

  end(event) {
    const id = event.item.id.split("_")[1];
    const data = new FormData();
    data.append("position", event.newIndex + 1);

    fetch(this.data.get("url").replace(":id", id), {
      method: "PATCH",
      body: data
    });
  }
}
