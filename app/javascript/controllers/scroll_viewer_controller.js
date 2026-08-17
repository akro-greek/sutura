import { Controller } from "@hotwired/stimulus"
import OpenSeadragon from "openseadragon"

export default class extends Controller {
  static values = { image: String, region: Object }

  connect() {
    if (!this.imageValue) return

    this.viewer = OpenSeadragon({
      element: this.element,
      tileSources: { type: "image", url: this.imageValue },
      prefixUrl: "https://cdn.jsdelivr.net/npm/openseadragon@5.0.1/build/openseadragon/images/",
      showNavigator: true,
      animationTime: 0.35,
      maxZoomPixelRatio: 4
    })
    this.viewer.addHandler("open", () => this.highlightRegion())
  }

  disconnect() {
    this.viewer?.destroy()
  }

  highlightRegion() {
    let { x, y, width, height, unit } = this.regionValue || {}
    if ([x, y, width, height].some((value) => value === undefined)) return

    if (unit === "percent") {
      const size = this.viewer.world.getItemAt(0).getContentSize()
      x = size.x * x / 100
      y = size.y * y / 100
      width = size.x * width / 100
      height = size.y * height / 100
    }

    const overlay = document.createElement("div")
    overlay.className = "sutura-region"
    const rect = this.viewer.viewport.imageToViewportRectangle(x, y, width, height)
    this.viewer.addOverlay({ element: overlay, location: rect })
    this.viewer.viewport.fitBounds(rect, true)
  }
}
