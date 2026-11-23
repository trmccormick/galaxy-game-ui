import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "description", "prerequisites", "raw", "status", "preview", "previewPanel"]

  connect() {
    this.originalDocument = this.rawTarget.value
    this.updateRaw()
  }

  updateStructured() {
    try {
      const document = JSON.parse(this.rawTarget.value)
      document.name = this.nameTarget.value
      document.description = this.descriptionTarget.value
      document.prerequisites = this.prerequisitesTarget.value
        .split(",")
        .map((value) => value.trim())
        .filter(Boolean)
      this.rawTarget.value = JSON.stringify(document, null, 2)
      this.setStatus("Structured fields synchronized with JSON.", "success")
    } catch (_error) {
      this.setStatus("Raw JSON is invalid. Correct it before editing structured fields.", "error")
    }
  }

  updateRaw() {
    try {
      const document = JSON.parse(this.rawTarget.value)
      this.nameTarget.value = document.name || ""
      this.descriptionTarget.value = document.description || ""
      this.prerequisitesTarget.value = (document.prerequisites || []).join(", ")
      this.setStatus("JSON is valid. Structured fields updated.", "success")
    } catch (error) {
      this.setStatus(`JSON syntax error: ${error.message}`, "error")
    }
  }

  format() {
    try {
      this.rawTarget.value = JSON.stringify(JSON.parse(this.rawTarget.value), null, 2)
      this.updateRaw()
    } catch (error) {
      this.setStatus(`Cannot format invalid JSON: ${error.message}`, "error")
    }
  }

  preview() {
    try {
      const current = JSON.stringify(JSON.parse(this.rawTarget.value), null, 2)
      this.previewTarget.textContent = current
      this.previewPanelTarget.hidden = false
      this.setStatus(current === this.originalDocument ? "Preview matches the source fixture." : "Preview shows unsaved prototype changes.", "success")
    } catch (error) {
      this.setStatus(`Preview unavailable: ${error.message}`, "error")
    }
  }

  setStatus(message, state) {
    this.statusTarget.textContent = message
    this.statusTarget.dataset.state = state
    this.statusTarget.style.color = state === "error" ? "var(--gg-accent-danger, #ff6b6b)" : "var(--gg-text-secondary)"
  }
}
