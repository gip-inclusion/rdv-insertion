import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["text"];
  
  connect() {
    this.phrases = [
      "gérer 30 000 rendez-vous RSA par mois",
      "atteindre les objectifs de délais de la LPE",
      "garantir une parfaite continuité des parcours des bRSA",
      "décupler le potentiel de votre logiciel de parcours",
    ];

    this.typeSpeed = 30;
    this.deleteSpeed = 15;
    this.pauseBetween = 2400;

    this.currentPhraseIndex = 0;
    this.currentText = "";
    this.isDeleting = false;
    this.timeoutId = null;

    this.tick();
  }

  disconnect() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
  }

  tick() {
    const phrase = this.phrases[this.currentPhraseIndex % this.phrases.length];

    if (this.isDeleting) {
      this.currentText = phrase.substring(0, this.currentText.length - 1);
    } else {
      this.currentText = phrase.substring(0, this.currentText.length + 1);
    }

    if (this.hasTextTarget) {
      this.textTarget.textContent = this.currentText;
    }

    let delta = this.isDeleting ? this.deleteSpeed : this.typeSpeed;

    if (!this.isDeleting && this.currentText === phrase) {
      this.isDeleting = true;
      delta = this.pauseBetween;
    } else if (this.isDeleting && this.currentText === "") {
      this.isDeleting = false;
      this.currentPhraseIndex = (this.currentPhraseIndex + 1) % this.phrases.length;
      delta = this.typeSpeed;
    }

    this.timeoutId = setTimeout(() => this.tick(), delta);
  }
} 