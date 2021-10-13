class ActionRequiredCheckbox {
  constructor() {
    this.inputElt = document.querySelector(".js-action-required-checkbox");
    if (this.inputElt === null) return;

    this.setIntialValue();
    this.attachListeners();
  }

  setIntialValue() {
    const url = new URL(window.location.href);
    const actionRequired = url.searchParams.get("action_required");
    if (actionRequired) {
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
      url.searchParams.set("action_required", true);
    } else {
      url.searchParams.delete("action_required");
    }
    window.location.href = url;
  }
}

export default ActionRequiredCheckbox;
