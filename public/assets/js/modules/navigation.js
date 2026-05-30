import { select, selectAll } from "./dom.js";

export function initNavigation() {
  const sections = ["install"]
    .map((id) => document.getElementById(id))
    .filter(Boolean);
  const navLinks = selectAll(".subnav__links a");

  if (!("IntersectionObserver" in window) || !sections.length) return;

  const spyObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        navLinks.forEach((link) => link.classList.remove("active"));
        const active = select(`.subnav__links a[href="#${entry.target.id}"]`);
        if (active) active.classList.add("active");
      });
    },
    { rootMargin: "-45% 0px -45% 0px", threshold: 0 }
  );

  sections.forEach((section) => spyObserver.observe(section));
}
