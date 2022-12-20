class FilterByCurrentAgentCheckbox {
  constructor() {
    this.inputElt = document.querySelector(".js-filter-by-current-agent-checkbox");
    if (this.inputElt === null) return;

    this.setIntialValue();
    this.attachListeners();
  }

  setIntialValue() {
    const url = new URL(window.location.href);
    const filteredByCurrentAgent = url.searchParams.get("filter_by_current_agent");
    if (filteredByCurrentAgent) {
      this.inputElt.checked = true;
    }
  }

  attachListeners() {
    this.inputElt.addEventListener("change", (event) => {
      this.refreshQuery(event.target);
    });
  }

  refreshQuery(input) {
    const url = new URL(window.location.href);
    if (input.checked) {
      url.searchParams.set("filter_by_current_agent", true);
    } else {
      url.searchParams.delete("filter_by_current_agent");
    }
    window.location.href = url;
  }
}

export default FilterByCurrentAgentCheckbox;
