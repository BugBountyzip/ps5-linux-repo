import { selectAll } from "./dom.js";

export function initReveal() {
  document.documentElement.classList.add("js");

  if (!("IntersectionObserver" in window)) {
    selectAll(".reveal").forEach((el) => el.classList.add("in-view"));
    return;
  }

  const revealObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        entry.target.classList.add("in-view");
        revealObserver.unobserve(entry.target);
      });
    },
    { threshold: 0.14 }
  );

  selectAll(".reveal").forEach((el) => revealObserver.observe(el));
}
