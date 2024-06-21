class OrientationSelector {
  constructor() {
    this.selectElt = document.querySelector(".js-orientation-selector");
    this.altLabel = document.querySelector(".orientation-label-alt");
    if (this.selectElt === null) return;

    this.setInitialValue();
    this.attachListener();
  }

  setInitialValue() {
    const url = new URL(window.location.href);
    const selectedOrientation = url.searchParams.get("orientation_type");
    if (selectedOrientation) {
      this.selectElt.value = selectedOrientation;
      this.setAlternativeLabel();
    }
  }

  setAlternativeLabel() {
    if (this.selectElt.value) {
      this.altLabel.innerText = `Type d'orientation : ${this.selectElt.options[this.selectElt.selectedIndex].text}`;
    } else {
      this.altLabel.innerText = "Filtrer par type d'orientation";
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
