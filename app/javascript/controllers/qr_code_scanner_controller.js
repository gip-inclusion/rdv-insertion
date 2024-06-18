import { Controller } from "@hotwired/stimulus";
import QrScanner from "qr-scanner";

export default class extends Controller {
  connect() {
    this.isScanning = false;
    this.qrScanner = null;
    document.querySelector("#scanner").addEventListener("click", () => this.scan());
  }

  scan() {
    document.querySelector(".qr-code-scanner").classList.remove("d-none");
    this.qrScanner = new QrScanner(
        document.querySelector("video"),
        result => this.handleScan(result),
    );
    this.isScanning = true;
    this.qrScanner.start();
    document.querySelector("#close").addEventListener("click", () => this.stopScan());
  }

  stopScan() {
    this.isScanning = false;
    this.qrScanner.stop();
    document.querySelector(".qr-code-scanner").classList.add("d-none");
  }

  handleScan(result) {
    if (result.includes("/i/r") && this.isScanning) {
      this.stopScan();
      const code = new URL(result).pathname.split("/").pop();
      console.log("Found QR code: ", code);
      
      window.location.replace(`/invitations/redirect?uuid=${code}`);
    }
  }
}
