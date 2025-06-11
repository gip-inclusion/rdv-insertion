class OrientationSelector {
  constructor() {
    this.selectElt = document.querySelector(".js-orientation-selector");
    if (this.selectElt === null) return;

    this.setInitialValue();
    this.attachListener();
  }

  setInitialValue() {
    const url = new URL(window.location.href);
    const selectedOrientation = url.searchParams.get("orientation_type");
    if (selectedOrientation) {
      this.selectElt.value = selectedOrientation;
    }
  }

  attachListener() {
    this.selectElt.addEventListener("change", (event) => {
      this.setAlternativeLabel();
      this.refreshQuery(event.target.value);
    });
  }

  refreshQuery(selectedOrientation) {
    const url = new URL(window.location.href);
    if (selectedOrientation) {
      url.searchParams.set("orientation_type", selectedOrientation);
    } else {
      url.searchParams.delete("orientation_type");
    }
    window.location.href = url;
  }
}

export default OrientationSelector;
