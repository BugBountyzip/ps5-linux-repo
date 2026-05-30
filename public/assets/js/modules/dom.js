export const select = (selector, root = document) => root.querySelector(selector);
export const selectAll = (selector, root = document) => Array.from(root.querySelectorAll(selector));
