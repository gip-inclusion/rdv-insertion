import Flatpickr from "stimulus-flatpickr";
import { French } from "flatpickr/dist/l10n/fr";

require("flatpickr/dist/flatpickr.css");
require("flatpickr/dist/themes/material_red.css");

export default class extends Flatpickr {
  initialize() {
    this.config = {
      locale: French,
    };
  }
}
