import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["step"];

  connect() {
    this.stepTargets.forEach(step => {
      step.classList.remove("active");
    });
  }
  
  toggleStep(event) {
    event.preventDefault();
    
    const currentStep = event.currentTarget;
    
    if (currentStep.classList.contains("active")) {
      currentStep.classList.remove("active");
    } else {
      this.stepTargets.forEach(step => {
        step.classList.remove("active");
      });
      currentStep.classList.add("active");
    }
  }
}
