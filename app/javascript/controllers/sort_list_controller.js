import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  initialize() {
    // if the page is rendered via turbo (= not full page reload), the connect() method is not called
    // so we have to listen to the turbo:render event to initialize the sorting
    document.addEventListener("turbo:render", () => this.initializeSorting())
  }

  connect() {
    this.initializeSorting();
  }

  disconnect() {
    document.removeEventListener("turbo:render", () => this.initializeSorting())
  }

  initializeSorting() {
    this.sortBy = new URL(window.location.href).searchParams.get("sort_by");
    this.sortDirection = new URL(window.location.href).searchParams.get("sort_direction");
    this.changeSortingArrow();
  }

  changeUrlParams(event) {
    const url = new URL(window.location.href);
    this.newSortBy = event.currentTarget.dataset.sortBy;
    // if a column is clicked for the third time, we remove the sorting
    if (this.sortDirection === undefined || this.newSortBy !== this.sortBy) {
      this.newSortDirection = "asc";
    } else if (this.sortDirection === "asc") {
      this.newSortDirection = "desc";
    } else if (this.sortDirection === "desc") {
      this.newSortDirection = undefined;
    }

    if (this.newSortDirection === undefined) {
      url.searchParams.delete("sort_by");
      url.searchParams.delete("sort_direction",);
    } else {
      url.searchParams.set("sort_by", this.newSortBy);
      url.searchParams.set("sort_direction", this.newSortDirection);
    }

    window.Turbo.visit(url, { action: "replace" });
  }

  changeSortingArrow() {
    const element = this.element.querySelector(`[data-sort-by="${this.sortBy}"]`);
    if (element && this.sortDirection) {
      const initialArrows = element.querySelector("i");
      const html = ` <i class="${this.sortDirection === "asc" ? "ri-arrow-up-line" : "ri-arrow-down-line"}" role="button"></i>`;
      initialArrows.remove();
      element.insertAdjacentHTML("beforeend", html);
    }
  }
}

