import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    const isExpandedInUrl = window.location.href.includes("expanded-filters=true");
    const exceedsMaxHeight = this.element.clientHeight > 200;

    if (exceedsMaxHeight) {
      if (isExpandedInUrl) {
        this.element.classList.add("is-expanded");
      } else {
        this.element.classList.add("is-collapsed");
      }
    }

    this.element.querySelectorAll("input[type=checkbox]").forEach((checkbox) => {
      if (checkbox.name.includes("[]")) {
        this.setInitialValueMultiple(checkbox);
        this.attachListenersMultiple(checkbox);
      } else {
        this.setInitialValue(checkbox);
        this.attachListeners(checkbox);
      }
    });
  }

  expand() {
    this.element.classList.remove("is-collapsed");
    this.element.classList.add("is-expanded");
    const url = new URL(window.location.href);
    url.searchParams.set("expanded-filters", "true");
    window.history.replaceState({}, "", url);
  }

  collapse() {
    this.element.classList.remove("is-expanded");
    this.element.classList.add("is-collapsed");
    const url = new URL(window.location.href);
    url.searchParams.delete("expanded-filters");
    window.history.replaceState({}, "", url);
  }

  setInitialValue(checkbox) {
    const url = new URL(window.location.href);
    const value = url.searchParams.get(checkbox.name);
    if (value) {
      checkbox.checked = true;
    }
  }

  setInitialValueMultiple(checkbox) {
    const url = new URL(window.location.href);
    const values = url.searchParams.getAll(checkbox.name);
    if (values.includes(checkbox.value)) {
      checkbox.checked = true;
    }
  }

  attachListeners(checkbox) {
    checkbox.addEventListener("change", () => {
      const url = new URL(window.location.href);

      if (checkbox.checked) {
        url.searchParams.set(checkbox.name, true);
      } else {
        url.searchParams.delete(checkbox.name);
      }
      window.location.href = url;
    });
  }

  attachListenersMultiple(checkbox) {
    checkbox.addEventListener("change", () => {
      const url = new URL(window.location.href);
      const values = url.searchParams.getAll(checkbox.name);
      if (checkbox.checked) {
        values.push(checkbox.value);
      } else {
        const index = values.indexOf(checkbox.value);
        if (index > -1) {
          values.splice(index, 1);
        }
      }
      url.searchParams.delete(checkbox.name);
      values.forEach((value) => {
        url.searchParams.append(checkbox.name, value);
      });

      window.location.href = url;
    });
  }
}
