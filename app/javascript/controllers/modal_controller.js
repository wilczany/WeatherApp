import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  connect() {
  }
  
  show(event) {
    const dialog = document.getElementById(event.params.dialog);
    dialog.showModal();
  }
}
