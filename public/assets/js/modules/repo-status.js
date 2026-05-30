import { select } from "./dom.js";

export async function initRepoStatus() {
  const status = select("[data-repo-status]");
  if (!status) return;

  try {
    const [metadata, key] = await Promise.all([
      fetch("./deb/InRelease", { cache: "no-store" }),
      fetch("./keys/ps5-linux-archive-key.asc", { cache: "no-store" }),
    ]);
    if (!metadata.ok || !key.ok) throw new Error("signed repository missing");
    status.textContent = "Signed APT metadata online";
    status.classList.add("online");
  } catch {
    status.textContent = "Signed APT metadata pending";
    status.classList.add("pending");
  }
}
