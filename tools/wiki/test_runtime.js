#!/usr/bin/env node
// Lightweight browser-surface smoke test for the wiki's real rendering code.
const fs = require("node:fs");
const vm = require("node:vm");
const path = require("node:path");
const root = path.resolve(__dirname, "../..");
const payload = JSON.parse(fs.readFileSync(path.join(root, "docs/wiki/catalog-data.json"), "utf8"));

class FakeElement {
  constructor(selector) {
    this.selector = selector;
    this.handlers = {};
    this.value = "";
    this.innerHTML = "";
    this.textContent = "";
    this.hidden = false;
    this.attributes = {};
    this.dataset = {};
    this.open = false;
    this.classList = { toggle() {} };
  }
  addEventListener(type, callback) { this.handlers[type] = callback; }
  setAttribute(name, value) { this.attributes[name] = value; }
  querySelectorAll() { return this.buttons || []; }
  querySelector() { return null; }
  focus() {}
  blur() {}
  showModal() { this.open = true; }
  close() { this.open = false; }
}

const selectors = [
  "#section-content", "#global-search", "#search-results", "#page-title", "#section-nav",
  "#lightbox", "#lightbox-title", "#lightbox-path", "#lightbox-image", "#lightbox-open", "#lightbox-close"
];
const elements = Object.fromEntries(selectors.map(selector => [selector, new FakeElement(selector)]));
const sectionIds = ["characters", "sprites", "attributes", "items", "combat", "world", "docs"];
elements["#section-nav"].buttons = sectionIds.map(id => {
  const button = new FakeElement(`[data-section=${id}]`);
  button.dataset.section = id;
  button.classList = { toggle() {} };
  return button;
});
global.document = {
  activeElement: { tagName: "BODY" },
  querySelector: selector => elements[selector],
  addEventListener(type, callback) { this.handlers ||= {}; this.handlers[type] = callback; }
};
global.fetch = async () => ({ ok: true, json: async () => payload });

vm.runInThisContext(fs.readFileSync(path.join(root, "docs/wiki/app.js"), "utf8"), { filename: "docs/wiki/app.js" });

setImmediate(() => {
  try {
    const content = elements["#section-content"];
    const search = elements["#global-search"];
    const nav = elements["#section-nav"];
    if (!content.innerHTML.includes("Melissa") || !content.innerHTML.includes("Guerreiro")) throw new Error("initial catalog section did not render");

    const navHandler = nav.handlers.click;
    navHandler({ target: { closest: () => nav.buttons.find(button => button.dataset.section === "combat") } });
    if (!content.innerHTML.includes("Combo") || !content.innerHTML.includes("Explosão de gelo")) throw new Error("combat section did not render all vocations");

    navHandler({ target: { closest: () => nav.buttons.find(button => button.dataset.section === "attributes") } });
    if (!content.innerHTML.includes("Regeneração por segundo") || !content.innerHTML.includes("1,2")) throw new Error("attribute and regeneration section did not render");

    navHandler({ target: { closest: () => nav.buttons.find(button => button.dataset.section === "items") } });
    if (!content.innerHTML.includes("Espada improvisada") || !content.innerHTML.includes("Curativo medicinal")) throw new Error("items section did not render equipment and consumables");

    navHandler({ target: { closest: () => nav.buttons.find(button => button.dataset.section === "world") } });
    if (!content.innerHTML.includes("Criaturas") || !content.innerHTML.includes("layout estático")) throw new Error("world section did not render layout and bestiary");

    search.value = "war_combo";
    search.handlers.input();
    if (!elements["#search-results"].innerHTML.includes("war_combo")) throw new Error("global search did not find a catalog ID");

    navHandler({ target: { closest: () => nav.buttons.find(button => button.dataset.section === "sprites") } });
    if (!content.innerHTML.includes("asset-card")) throw new Error("sprite catalog did not render previews");
    const filterHandler = content.handlers.click;
    filterHandler({ target: { closest: selector => selector === "[data-asset-filter]" ? { dataset: { assetFilter: "creatures" } } : null } });
    if (!content.innerHTML.includes("fox_se_candidate") || content.innerHTML.includes("melissa_warrior")) throw new Error("sprite category filter did not constrain assets");

    navHandler({ target: { closest: () => nav.buttons.find(button => button.dataset.section === "docs") } });
    const firstPage = content.innerHTML;
    content.handlers.click({ target: { closest: selector => selector === "[data-page]" ? { dataset: { page: "next" }, disabled: false } : null } });
    if (content.innerHTML === firstPage) throw new Error("file index pagination did not update");
    console.log("PASS runtime wiki: sete seções, busca, filtros de PNG e paginação renderizados.");
  } catch (error) {
    console.error(`FAIL runtime wiki: ${error.message}`);
    process.exitCode = 1;
  }
});
