import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["feature"];

  toggleFeature(event) {
    event.preventDefault();
    
    const currentFeature = event.currentTarget;
    
    if (currentFeature.classList.contains("active")) {
      currentFeature.classList.remove("active");
    } else {
      this.featureTargets.forEach(feature => {
        feature.classList.remove("active");
      });
      currentFeature.classList.add("active");
    }
  }
}