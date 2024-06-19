import { Controller } from "@hotwired/stimulus";
import QrScanner from "qr-scanner";

export default class extends Controller {
  connect() {
    this.isScanning = false;
    this.qrScanner = null;
  }

  scan() {
    document.querySelector(".qr-code-scanner").classList.remove("d-none");
    this.qrScanner = new QrScanner(
        document.querySelector("video"),
        result => this.handleScan(result),
    );
    this.isScanning = true;
    this.qrScanner.start();
  }

  stopScan() {
    this.isScanning = false;
    this.qrScanner.stop();
    document.querySelector(".qr-code-scanner").classList.add("d-none");
  }

  handleScan(result) {
    if (result.includes("/i/r") && this.isScanning) {
      this.stopScan();
      const uuid = new URL(result).pathname.split("/").pop();
      window.location.replace(`/invitations/redirect?uuid=${uuid}`);
    }
  }
}
