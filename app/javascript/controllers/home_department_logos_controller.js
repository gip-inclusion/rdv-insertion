import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  scrollToMap(event) {
    event.preventDefault();
    
    const mapSection = document.querySelector("#home-trust-title");
    const targetPosition = mapSection.getBoundingClientRect().top;
    const headerOffset = 80;
    const offsetPosition = targetPosition + window.pageYOffset - headerOffset;

    window.scrollTo({ top: offsetPosition, behavior: "smooth" });
  }
}
