import { select, selectAll } from "./dom.js";
import { showToast } from "./toast.js";

export function initCopyButtons() {
  selectAll("[data-copy]").forEach((button) => {
    button.addEventListener("click", async () => {
      const target = select(button.dataset.copy);
      if (!target) return;

      try {
        await navigator.clipboard.writeText(target.textContent.trim());
        showToast("Command copied");
      } catch {
        showToast("Copy failed");
      }
    });
  });
}
