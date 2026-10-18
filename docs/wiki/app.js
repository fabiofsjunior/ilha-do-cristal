(() => {
  "use strict";

  const $ = (selector, root = document) => root.querySelector(selector);
  const sectionRoot = $("#section-content");
  const searchInput = $("#global-search");
  const searchResults = $("#search-results");
  const titleNode = $("#page-title");
  const nav = $("#section-nav");
  const themeToggle = $("#theme-toggle");
  const themeToggleLabel = $("#theme-toggle-label");
  const themeToggleIcon = $("#theme-toggle-icon");
  const themeMeta = $('meta[name="theme-color"]');
  const THEME_STORAGE_KEY = "ilha-cristal-wiki-theme";

  function applyTheme(theme) {
    const nextTheme = theme === "light" ? "light" : "dark";
    const isDark = nextTheme === "dark";
    const actionLabel = isDark ? "Desativar modo escuro" : "Ativar modo escuro";
    document.documentElement.dataset.theme = nextTheme;
    document.documentElement.style.colorScheme = nextTheme;
    themeToggle.setAttribute("aria-label", actionLabel);
    themeToggle.setAttribute("aria-pressed", String(isDark));
    themeToggleLabel.textContent = actionLabel;
    themeToggleIcon.textContent = isDark ? "☼" : "☾";
    themeMeta.content = isDark ? "#101819" : "#f4f2e9";
  }

  function persistTheme(theme) {
    try {
      localStorage.setItem(THEME_STORAGE_KEY, theme);
    } catch (error) {
      console.warn("Não foi possível salvar a preferência de tema; a alteração vale apenas nesta sessão.", error);
    }
  }

  applyTheme(document.documentElement.dataset.theme);
  themeToggle.addEventListener("click", () => {
    const nextTheme = document.documentElement.dataset.theme === "dark" ? "light" : "dark";
    applyTheme(nextTheme);
    persistTheme(nextTheme);
  });
  const names = {
    sections: {
      characters: "Personagens & vocações", sprites: "Sprites & atlas", attributes: "Atributos & níveis",
      items: "Itens & equipamento", combat: "Habilidades & combate", world: "Mundo & criaturas", docs: "Documentação"
    },
    characters: { melissa: "Melissa", helena: "Helena", maira: "Maíra", fabio: "Fábio" },
    vocations: { warrior: "Guerreiro", archer: "Arqueiro", mage: "Mago" },
    stats: { str: "FOR", agi: "AGI", int: "INT" },
    items: {
      sword_basic: "Espada improvisada", sword_reinforced: "Espada reforçada", bow_basic: "Arco improvisado",
      bow_reinforced: "Arco reforçado", staff_basic: "Cajado improvisado", staff_crystal: "Cajado cristalino",
      axe_basic: "Machado", pickaxe_basic: "Picareta", wood: "Madeira", stone: "Pedra", fiber: "Fibra",
      herb: "Erva", meat: "Carne", hide: "Couro", fang: "Presa", crystal_shard: "Fragmento cristalino",
      bandage: "Curativo medicinal", pure_crystal: "Cristal puro", campfire: "Fogueira", tent: "Barraca",
      workbench: "Bancada", shared_chest: "Baú compartilhado", well: "Poço", palisade: "Paliçada", watchtower: "Torre de vigia"
    },
    skills: {
      war_combo: "Combo", war_circle: "Corte circular", war_quake: "Terremoto", arc_precise: "Disparo preciso",
      arc_bounce: "Ricochete", arc_pierce: "Flecha perfurante", mag_bolt: "Projétil arcano", mag_fire: "Bola de fogo", mag_ice: "Explosão de gelo"
    },
    targets: { single: "Alvo único", adjacent_aoe: "Área adjacente", aoe: "Área", chain: "Cadeia", line: "Linha", radius: "Raio" },
    terrain: { water_deep: "Água profunda", water_shallow: "Água rasa", sand: "Areia", grass: "Grama", soil: "Solo", forest: "Floresta" },
    creatures: { fox: "Raposa", wolf: "Lobo", bear: "Urso" },
    regions: { beach_spawn: "Praia inicial", green_forest: "Floresta verde", bear_interior: "Interior do urso", corrupted_castle: "Castelo corrompido (conceito)" }
  };
  const skillEffects = {
    war_combo: "3 golpes; não atordoa. O efeito de item aplica no máximo uma vez.",
    war_circle: "Sangra 1% do HP máximo do alvo por segundo durante 5 s; cada tick fica limitado a 20% AF e o efeito não acumula.",
    war_quake: "Derruba/atordoa por 3 s.",
    arc_precise: "Invisibilidade por até 3 s; o próximo disparo encerra o efeito e não recebe um segundo multiplicador crítico.",
    arc_bounce: "Atinge alvos distintos em sequência.",
    arc_pierce: "Acertar aumenta a velocidade de ataque em 25% por 6 s, uma vez por uso.",
    mag_bolt: "Dano mágico em um alvo.",
    mag_fire: "Queima por 6 s; não acumula nem se propaga no MVP.",
    mag_ice: "Raio curto; sem controle adicional no MVP."
  };
  const statusNames = {
    bleed: "sangramento", burn: "queimadura", stun: "atordoamento", invisible: "invisibilidade",
    attack_speed_up: "velocidade de ataque", downed: "caído"
  };
  const groupLabels = { characters: "Personagens", creatures: "Criaturas", environments: "Terreno", ui: "Interface" };
  let data;
  let activeSection = "characters";
  let assetFilter = "all";
  let filePage = 0;
  const PAGE_SIZE = 60;

  function escapeHtml(value) {
    return String(value ?? "").replace(/[&<>"']/g, char => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[char]);
  }
  function norm(value) {
    return String(value ?? "").normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLocaleLowerCase("pt-BR");
  }
  function number(value, digits = 2) {
    if (value === null || value === undefined || value === "") return "—";
    return new Intl.NumberFormat("pt-BR", { maximumFractionDigits: digits }).format(value);
  }
  function prettyId(id, dictionary) {
    return dictionary[id] || String(id || "").replaceAll("_", " ");
  }
  function file(path) {
    return data.files.find(entry => entry.path === path);
  }
  function fileLink(path, label = path) {
    const found = file(path);
    return found ? `<a href="${escapeHtml(found.href)}">${escapeHtml(label)}</a>` : `<span class="mono">${escapeHtml(label)} (arquivo ausente)</span>`;
  }
  function sourceLink(path) {
    return `<a class="source-link" href="${escapeHtml(file(path)?.href || `../../${path}`)}">fonte ↗</a>`;
  }
  function tag(text, kind = "neutral") { return `<span class="tag ${kind}">${escapeHtml(text)}</span>`; }
  function sectionHeader(title, description, source) {
    return `<div class="section-head"><div><h2>${escapeHtml(title)}</h2><p>${escapeHtml(description)}</p></div>${sourceLink(source)}</div>`;
  }
  function notice(text, label = "Nota de fonte") {
    return `<div class="notice"><strong>${escapeHtml(label)}:</strong> ${escapeHtml(text)}</div>`;
  }
  function sourceStatus(asset) {
    if (asset.approved === true) return tag("aprovado", "neutral");
    if (asset.status === "corrigir") return tag("corrigir", "warn");
    if (asset.status === "candidate") return tag("candidato", "warn");
    if (asset.status || asset.approved === false) return tag(asset.status || "não aprovado", "warn");
    return tag("sem status no metadado");
  }
  function statStrip(cards) {
    return `<div class="stats-strip">${cards.map(([label, value, sub]) => `<div class="stat-card"><span class="stat-label">${escapeHtml(label)}</span><div class="stat-value">${escapeHtml(value)}</div><div class="stat-sub">${escapeHtml(sub)}</div></div>`).join("")}</div>`;
  }

  function renderCharacters() {
    const catalog = data.catalog;
    const appearanceMap = new Map(data.appearances.characters.map(entry => [entry.id, entry]));
    const characterCards = catalog.characters.map(character => {
      const appearance = appearanceMap.get(character.id);
      const idleMetadata = appearance?.idle_metadata?.replace(/^res:\/\//, "");
      const walkMetadata = appearance?.walk_metadata?.replace(/^res:\/\//, "");
      const idlePng = idleMetadata?.replace(/\.json$/, ".png");
      const asset = data.assets.find(entry => entry.path === idlePng);
      return `<article class="card"><div class="identity-row"><div class="identity-preview">${asset ? `<button type="button" class="identity-lightbox" data-lightbox="${escapeHtml(asset.href)}" data-title="${escapeHtml(asset.name)}"><img src="${escapeHtml(asset.href)}" alt="Prévia candidata de ${escapeHtml(prettyId(character.id, names.characters))}" loading="lazy"></button>` : `<span class="mono">${escapeHtml(character.id)}</span>`}</div><div><div class="card-top"><h3>${escapeHtml(prettyId(character.id, names.characters))}</h3>${tag("aparência livre")}</div><p>${escapeHtml(character.description)}</p></div></div><p><strong>Identidade visual:</strong> ${escapeHtml(character.visual)}</p><div class="asset-meta">${fileLink(idleMetadata || "", "atlas idle .json")} · ${fileLink(walkMetadata || "", "atlas walk .json")}</div></article>`;
    }).join("");
    const vocations = catalog.vocations.map(vocation => {
      const multipliers = vocation.stat_multiplier;
      return `<article class="card vocation-card"><div class="card-top"><h3 class="vocation-name">${escapeHtml(prettyId(vocation.id, names.vocations))}</h3>${tag(`ID ${vocation.id}`)}</div><div class="metric-row"><div class="metric"><span>HP BASE</span><strong>${number(vocation.hp, 0)}</strong></div><div class="metric"><span>MP BASE</span><strong>${number(vocation.mp, 0)}</strong></div></div><div class="mult-list">${["str", "agi", "int"].map(stat => `<div class="mult-line"><span>${names.stats[stat]} · efetivo por ponto bruto</span><strong>×${number(multipliers[stat], 2)}</strong></div>`).join("")}</div></article>`;
    }).join("");
    return `${sectionHeader("Personagens", "Quatro aparências disponíveis para cada vocação. A escolha de vocação é permanente por personagem.", "Docs/Main/CATALOGS_MVP.md")}${statStrip([["Aparências", String(catalog.characters.length), "identidades descritas no catálogo"], ["Vocações", String(catalog.vocations.length), "Warrior · Archer · Mage"], ["Combinações", String(catalog.characters.length * catalog.vocations.length), "aparência × vocação possíveis"], ["Equipamento", "sem efeito", "não muda o visual do personagem"]])}<div class="grid">${characterCards}</div><div class="section-head subhead"><div><h2>Vocações</h2><p>HP/MP iniciais e multiplicadores do catálogo versionado.</p></div>${sourceLink("data/catalogs/mvp.json")}</div><div class="grid three">${vocations}</div>`;
  }

  function renderAssets(filter = assetFilter) {
    const groups = ["all", "characters", "creatures", "environments", "ui"];
    const labels = { all: "Todos", ...groupLabels };
    const assets = data.assets.filter(asset => filter === "all" || asset.group === filter);
    const chips = groups.map(group => `<button class="filter-chip ${filter === group ? "active" : ""}" type="button" data-asset-filter="${group}" aria-pressed="${filter === group}">${escapeHtml(labels[group])}${group === "all" ? ` · ${data.assets.length}` : ` · ${data.assets.filter(item => item.group === group).length}`}</button>`).join("");
    const cards = assets.map(asset => {
      const dimensions = asset.dimensions ? `${asset.dimensions[0]}×${asset.dimensions[1]} px` : "PNG";
      const frameInfo = asset.cell ? `célula ${asset.cell.join("×")} · ${asset.directions || "—"} dir. · pivô ${asset.pivot?.join(", ") || "—"}` : dimensions;
      return `<article class="asset-card"><button class="thumb" type="button" data-lightbox="${escapeHtml(asset.href)}" data-title="${escapeHtml(asset.name)}"><img src="${escapeHtml(asset.href)}" alt="Prévia pixelada: ${escapeHtml(asset.name)}" loading="lazy"></button><div class="asset-title">${escapeHtml(asset.name)}</div><div class="asset-meta">${sourceStatus(asset)}<span>${escapeHtml(frameInfo)}</span></div><div class="asset-path">${fileLink(asset.path, "ver arquivo PNG ↗")}</div></article>`;
    }).join("");
    return `${sectionHeader("Sprites & atlas", "Prévia ampliável e caminho para PNG original. Status vem do metadado ao lado; sem status explícito, o catálogo não presume aprovação.", "docs/art/ART_DIRECTION_AND_SPRITES.md")}${notice("Os arquivos mostrados são candidatos de trabalho. A maioria das artes de personagens/criaturas ainda está marcada como corrigir ou não aprovada; a revisão Android continua pendente.", "Estado da arte") }<div class="pill-row">${chips}</div>${assets.length ? `<div class="asset-grid">${cards}</div>` : `<div class="empty-state">Nenhum arquivo de imagem nesta categoria.</div>`}`;
  }

  function renderAttributes() {
    const catalog = data.catalog;
    const levels = catalog.attributes_and_levels;
    const regen = levels.regeneration;
    const regenFactor = regen.out_of_combat_rate_multiplier;
    const vocations = catalog.vocations;
    let cumulative = 0;
    const xpRows = levels.xp_to_next_level_from_1_to_9.map((xp, index) => {
      cumulative += xp;
      return `<tr><td>${index + 2}</td><td>${number(xp, 0)}</td><td>${number(cumulative, 0)}</td><td>${index + 1}</td></tr>`;
    }).join("");
    const baseRows = vocations.map(vocation => {
      const base = regen.base_percent_per_sec;
      const hp = base.hp[vocation.id];
      const mp = base.mp[vocation.id];
      return `<tr><td>${prettyId(vocation.id, names.vocations)}</td><td>${number(hp.combat, 3)}%</td><td>${number(hp.outside_combat, 3)} × ${number(regenFactor, 2)} = ${number(hp.outside_combat * regenFactor, 3)}%</td><td>${number(mp.combat, 3)}%</td><td>${number(mp.outside_combat, 3)} × ${number(regenFactor, 2)} = ${number(mp.outside_combat * regenFactor, 3)}%</td></tr>`;
    }).join("");
    const multiplierRows = vocations.map(vocation => `<tr><td>${prettyId(vocation.id, names.vocations)}</td><td>${vocation.hp}/${vocation.mp}</td><td>×${number(vocation.stat_multiplier.str)} / ×${number(vocation.stat_multiplier.agi)} / ×${number(vocation.stat_multiplier.int)}</td></tr>`).join("");
    const bonus = regen.effective_attribute_bonus_percentage_points_per_sec;
    return `${sectionHeader("Atributos & níveis", "Base, multiplicadores, regeneração e curva de XP publicada no catálogo de planejamento.", "Docs/Main/CONTENT_DATA.md")}${notice("Os números são valores de teste versionados e não prometem equilíbrio final. A regeneração fora de combate aplica o fator 1,2 antes do limite; os bônus de atributo usam o valor efetivo da vocação.", "Valores provisórios") }<div class="grid three"><article class="card"><h3>FOR · Força</h3><p>Dano físico corpo a corpo, HP e regeneração de HP.</p></article><article class="card"><h3>AGI · Agilidade</h3><p>Dano físico à distância, crítico e esquiva.</p></article><article class="card"><h3>INT · Inteligência</h3><p>Mana, regeneração de MP e dano mágico.</p></article></div><div class="section-head subhead"><div><h2>Base e multiplicadores</h2><p>Multiplicadores aplicados ao ponto bruto para obter atributo efetivo.</p></div>${sourceLink("data/catalogs/mvp.json")}</div><div class="table-wrap"><table><thead><tr><th>Vocação</th><th>HP / MP base</th><th>FOR / AGI / INT</th></tr></thead><tbody>${multiplierRows}</tbody></table></div><div class="section-head subhead"><div><h2>Regeneração por segundo</h2><p>Taxas base em % do máximo atual, antes de aplicar bônus de atributo e tetos.</p></div></div><div class="table-wrap"><table><thead><tr><th>Vocação</th><th>HP combate</th><th>HP fora</th><th>MP combate</th><th>MP fora</th></tr></thead><tbody>${baseRows}</tbody></table></div><div class="pill-row">${tag(`${number(regen.out_of_combat_delay_sec, 0)} s sem atacar/receber dano`, "neutral")}${tag(`Fora de combate ×${number(regenFactor, 2)}`, "neutral")}${tag(`Limite HP: ${number(levels.hp_regen_cap_inside_combat_percent_per_sec)}% / ${number(levels.hp_regen_cap_outside_combat_percent_per_sec)}%`, "neutral")}${tag(`Limite MP: ${number(levels.mp_regen_cap_inside_combat_percent_per_sec)}% / ${number(levels.mp_regen_cap_outside_combat_percent_per_sec)}%`, "neutral")}</div><p class="intro-copy">Bônus por ponto efetivo, já com o fator fora de combate: FOR +${number(bonus.FOR.combat, 3)} p.p. de HP/s em combate e +${number(bonus.FOR.outside_combat * regenFactor, 4)} fora; INT +${number(bonus.INT.combat, 3)} p.p. de MP/s em combate e +${number(bonus.INT.outside_combat * regenFactor, 4)} fora.</p><div class="section-head subhead"><div><h2>Progressão do MVP</h2><p>XP desde o nível anterior e total acumulado derivado da curva do JSON.</p></div></div><div class="table-wrap"><table><thead><tr><th>Nível alcançado</th><th>XP necessário</th><th>XP total</th><th>Pontos brutos de atributo obtidos</th></tr></thead><tbody><tr><td>1</td><td>0</td><td>0</td><td>0</td></tr>${xpRows}</tbody></table></div><p class="intro-copy">Nível máximo planejado: ${number(levels.level_cap_mvp, 0)}. Ao subir, recebe ${number(levels.attribute_points_per_level_up, 0)} ponto bruto de atributo. A árvore começa com ${number(levels.talent_points_at_creation, 0)} pontos e dá ${number(levels.talent_points_per_level_up_until_50, 0)} por nível até 50. Crítico e esquiva têm limite de ${number(levels.crit_cap_percent, 0)}%.</p>`;
  }

  function renderItems() {
    const catalog = data.catalog;
    const weapons = catalog.weapons_and_tools;
    const resources = catalog.resources;
    const consumables = catalog.consumables;
    const recipes = catalog.recipes;
    const buildings = catalog.buildings;
    const campLevels = catalog.camp_upgrades;
    const weaponRows = weapons.map(item => `<tr><td>${prettyId(item.id, names.items)}<span class="id-label">${item.id}</span></td><td>${item.vocation ? prettyId(item.vocation, names.vocations) : "Todas · ferramenta"}</td><td>${item.damage !== undefined ? `${item.damage} ${item.damage_type === "magic" ? "AM" : "AF"}` : item.role ? item.role === "wood_harvest" ? "extração de madeira" : "extração de pedra" : "—"}</td><td>${item.range_tiles !== undefined ? `${item.range_tiles} SQM` : "—"}</td></tr>`).join("");
    const resourceRows = resources.map(item => `<tr><td>${prettyId(item.id, names.items)}<span class="id-label">${item.id}</span></td><td>${item.xp_per_extraction === null || item.xp_per_extraction === undefined ? "não definido" : `${item.xp_per_extraction} XP`}</td></tr>`).join("");
    const recipeRows = recipes.map(recipe => {
      const requirements = Object.entries(recipe.requires).map(([id, count]) => `${count} ${prettyId(id, names.items).toLocaleLowerCase("pt-BR")}`).join(" + ");
      return `<tr><td>${prettyId(recipe.output, names.items)}<span class="id-label">${recipe.id}</span></td><td>${escapeHtml(requirements)}</td><td>${recipe.id.includes("upgrade") ? "Bancada nível II · provisório" : "Bancada/fogueira inicial · planeado"}</td></tr>`;
    }).join("");
    const buildingRows = buildings.map(building => `<tr><td>${prettyId(building.id, names.items)}<span class="id-label">${building.id}</span></td><td>${building.camp_level}</td><td>${building.max_count ? `máximo ${building.max_count}` : "—"}</td></tr>`).join("");
    const upgradeRows = campLevels.map(upgrade => `<tr><td>Nível ${upgrade.to_level}</td><td>${Object.entries(upgrade.requires).map(([id, count]) => `${count} ${prettyId(id, names.items).toLocaleLowerCase("pt-BR")}`).join(" + ")}</td></tr>`).join("");
    return `${sectionHeader("Itens & equipamento", "Armas, ferramentas, recursos, consumíveis, receitas e construções listados para o MVP.", "Docs/Main/CATALOGS_MVP.md")}${notice("O catálogo em JSON é planejamento e não é consumido pelo jogo como balanceamento final. Itens de armadura/acessórios e atributos desses equipamentos ainda não têm catálogo aprovado.", "Escopo do dado") }<div class="section-head subhead"><div><h2>Armas &amp; ferramentas</h2><p>Dano, vocação e alcance disponíveis no JSON.</p></div></div><div class="table-wrap"><table><thead><tr><th>Item</th><th>Uso/vocação</th><th>Dano ou função</th><th>Alcance</th></tr></thead><tbody>${weaponRows}</tbody></table></div><div class="section-head subhead"><div><h2>Recursos</h2><p>XP de extração conforme campo presente no dado.</p></div></div><div class="table-wrap"><table><thead><tr><th>Recurso</th><th>XP por extração</th></tr></thead><tbody>${resourceRows}</tbody></table></div><div class="section-head subhead"><div><h2>Consumível</h2><p>Quantidade e duração são os valores do catálogo.</p></div></div><div class="grid">${consumables.map(item => `<article class="card"><div class="card-top"><h3>${prettyId(item.id, names.items)}</h3>${tag("planejamento", "warn")}</div><div class="metric-row"><div class="metric"><span>CURA HP</span><strong>${number(item.healing_hp, 0)}</strong></div><div class="metric"><span>DURAÇÃO</span><strong>${number(item.duration_sec, 0)} s</strong></div></div><p>${item.interrupted_by_attack ? "Interrompido ao atacar." : "Sem regra de interrupção registrada."}</p><span class="id-label">${item.id}</span></article>`).join("")}</div><div class="section-head subhead"><div><h2>Receitas</h2><p>Os custos de melhoria permanecem provisórios para playtest.</p></div></div><div class="table-wrap"><table><thead><tr><th>Produto</th><th>Insumos</th><th>Estação/estado</th></tr></thead><tbody>${recipeRows}</tbody></table></div><div class="section-head subhead"><div><h2>Acampamento</h2><p>Construções por nível conforme a lista versionada.</p></div></div><div class="table-wrap"><table><thead><tr><th>Construção</th><th>Nível</th><th>Limite registrado</th></tr></thead><tbody>${buildingRows}</tbody></table></div><div class="table-wrap camp-table"><table><thead><tr><th>Melhoria</th><th>Insumos</th></tr></thead><tbody>${upgradeRows}</tbody></table></div>`;
  }

  function skillDamage(skill) {
    const parts = [];
    if (skill.hits) parts.push(`${skill.hits} × ${skill.physical_percent_each_hit}% AF/golpe`);
    if (skill.physical_percent_each_target) parts.push(`${skill.physical_percent_each_target.join(" / ")}% AF por alvo`);
    if (skill.physical_percent !== undefined) parts.push(`${skill.physical_percent}% AF`);
    if (skill.magic_percent !== undefined) parts.push(`${skill.magic_percent}% AM`);
    return parts.length ? parts.join(" + ") : "—";
  }
  function renderCombat() {
    const catalog = data.catalog;
    const skillsByVocation = catalog.vocations.map(vocation => {
      const skills = catalog.skills.filter(skill => skill.vocation === vocation.id);
      const cards = skills.map(skill => `<article class="card"><div class="card-top"><div><h3>${prettyId(skill.id, names.skills)}</h3><span class="id-label">${skill.id}</span></div>${tag(prettyId(skill.target, names.targets))}</div><p class="skill-damage">${escapeHtml(skillDamage(skill))}</p><p>${escapeHtml(skillEffects[skill.id] || "Efeito descrito no catálogo de produção.")}</p><div class="metric-row"><div class="metric"><span>RECARGA</span><strong>${number(skill.cooldown_sec, 0)} s</strong></div><div class="metric"><span>CUSTO</span><strong>${number(skill.mp, 0)} MP</strong></div></div></article>`).join("");
      return `<div class="section-head subhead"><div><h2>${prettyId(vocation.id, names.vocations)} <span class="id-label">${skills.length} habilidades previstas</span></h2></div></div><div class="grid three">${cards}</div>`;
    }).join("");
    const effects = catalog.status_effects.map(status => tag(prettyId(status, statusNames), "neutral")).join("");
    return `${sectionHeader("Habilidades & combate", "As nove habilidades e custos publicados no catálogo inicial. Os efeitos seguem a descrição do GDD.", "Docs/Main/GDD_MVP.md")}${notice("As nove habilidades são conteúdo planeado. O recorte solo implementado atualmente oferece as três habilidades de Warrior; Archer/Mage permanecem pendentes.", "Estado de implementação") }${skillsByVocation}<div class="section-head subhead"><div><h2>Estados catalogados</h2><p>Estados mencionados no arquivo de dados.</p></div>${sourceLink("data/catalogs/mvp.json")}</div><div class="pill-row">${effects}</div><div class="card"><h3>Modelo de ataque</h3><p>AF = ataque físico após arma/atributos; AM = ataque mágico. O ataque básico Warrior no recorte jogável usa alvo automático dentro do alcance. Esta descrição resume o GDD; alcance, raio, defesa e custos ainda precisam de playtest.</p>${fileLink("game/scripts/combat/combat_rules.gd", "Abrir regras de combate implementadas ↗")}</div>`;
  }

  function renderWorld() {
    const catalog = data.catalog;
    const layout = data.layout;
    const width = layout.grid_size[0];
    const height = layout.grid_size[1];
    const spawnCounts = {};
    for (const spawn of layout.creature_spawns) spawnCounts[spawn.species] = (spawnCounts[spawn.species] || 0) + 1;
    const monsterCards = catalog.monsters.map(monster => {
      const creatureAsset = data.assets.find(asset => asset.group === "creatures" && asset.path.includes(`/${monster.id}/`));
      const drops = monster.drops.map(drop => `${drop.quantity} ${prettyId(drop.item, names.items).toLocaleLowerCase("pt-BR")}${drop.chance < 1 ? ` (${number(drop.chance * 100, 0)}%)` : ""}`).join(" · ");
      return `<article class="card"><div class="card-top"><h3>${prettyId(monster.id, names.creatures)}</h3>${tag(`${spawnCounts[monster.id] || 0} posições no layout`, "neutral")}</div>${creatureAsset ? `<button class="creature-preview" type="button" data-lightbox="${escapeHtml(creatureAsset.href)}" data-title="${escapeHtml(creatureAsset.name)}"><img src="${escapeHtml(creatureAsset.href)}" alt="Prévia candidata da ${prettyId(monster.id, names.creatures)}" loading="lazy"></button>` : ""}<div class="metric-row"><div class="metric"><span>HP</span><strong>${monster.hp}</strong></div><div class="metric"><span>ATAQUE</span><strong>${monster.attack}</strong></div><div class="metric"><span>XP</span><strong>${monster.xp}</strong></div></div><p>Região do catálogo: ${escapeHtml(prettyId(monster.region, names.regions))}.</p><p><strong>Drops:</strong> ${escapeHtml(drops)}</p><span class="id-label">${monster.id} · dados de planejamento</span></article>`;
    }).join("");
    const bandRows = layout.surface_bands.map(band => `<tr><td>${prettyId(band.group, names.terrain)}</td><td>x ${band.from_x}–${band.to_x - 1}</td></tr>`).join("");
    const forestRows = layout.surface_areas.map((area, i) => `<tr><td>Área florestal ${i + 1}</td><td>x ${area.from_x}–${area.to_x - 1}; y ${area.from_y}–${area.to_y - 1}</td></tr>`).join("");
    const bandCounts = layout.surface_bands.length;
    const totalHarvest = layout.harvest_nodes.length;
    const resourceCounts = layout.harvest_nodes.reduce((counts, node) => { counts[node.resource] = (counts[node.resource] || 0) + 1; return counts; }, {});
    const mapImage = data.assets.find(asset => asset.path === "assets/environments/terrain_mvp_candidate_v1/terrain_mvp_candidate_v1.png");
    const actualRegionRows = [
      ["Praia / spawn", "zona inicial protegida e recursos básicos"],
      ["Floresta verde", "raposas/lobos, árvores, rochas e pontos de interesse"],
      ["Interior do urso", "ursos, cristais e objetivo do MVP"],
      ["Castelo corrompido", "somente conceito; sem conteúdo jogável no MVP"]
    ].map(([region, description]) => `<tr><td>${escapeHtml(region)}</td><td>${escapeHtml(description)}</td><td>${region.includes("Castelo") ? tag("conceptual", "warn") : tag("planejado", "neutral")}</td></tr>`).join("");
    return `${sectionHeader("Mundo, terreno & criaturas", "Dados do layout jogável estático e conteúdo de regiões planejado para o MVP.", "game/data/first_island_layout.json")}${notice("O recorte atual usa layout estático de ${width}×${height} SQMs. A geração procedural por seed/chunks e a ilha de até 1000×1000 tiles pertencem ao plano do MVP e ainda estão pendentes.", "Recorte atual")}${statStrip([["Mapa", `${width}×${height}`, "SQMs no layout versionado"], ["Seed", String(layout.seed), "layout atual"], ["Faixas", String(bandCounts), "superfície por coluna x"], ["Pontos de coleta", String(totalHarvest), `${resourceCounts.fiber || 0} fibra · ${resourceCounts.herb || 0} erva`]])}<div class="grid">${mapImage ? `<article class="card"><div class="card-top"><h3>Atlas de terreno candidato</h3>${sourceStatus(mapImage)}</div><button class="world-preview" type="button" data-lightbox="${escapeHtml(mapImage.href)}" data-title="${escapeHtml(mapImage.name)}"><img src="${escapeHtml(mapImage.href)}" alt="Prévia do atlas de terreno candidato" loading="lazy"></button><div class="asset-path">${fileLink(mapImage.path, "ver PNG original ↗")}</div></article>` : ""}<article class="card"><h3>Spawn &amp; marcos</h3><div class="metric-row"><div class="metric"><span>SPAWN</span><strong>${layout.spawn_cell.join(", ")}</strong></div><div class="metric"><span>CRISTAL</span><strong>${layout.beacon_cell.join(", ")}</strong></div><div class="metric"><span>TILE CANDIDATO</span><strong>${layout.tile_px_candidate.join("×")} px</strong></div></div><p>Coordenadas do arquivo, em células [x, y].</p></article></div><div class="section-head subhead"><div><h2>Superfície no layout</h2><p>Intervalos extraídos do arquivo do mapa; fim de faixa exclusivo.</p></div></div><div class="table-wrap"><table><thead><tr><th>Superfície</th><th>Colunas</th></tr></thead><tbody>${bandRows}</tbody></table></div><div class="table-wrap camp-table"><table><thead><tr><th>Área</th><th>Retângulo [x, y]</th></tr></thead><tbody>${forestRows}</tbody></table></div><div class="section-head subhead"><div><h2>Criaturas</h2><p>Contagem de posições no layout e atributos do catálogo de planejamento.</p></div>${sourceLink("Docs/Main/CONTENT_DATA.md")}</div><div class="grid three">${monsterCards}</div><div class="section-head subhead"><div><h2>Regiões planejadas</h2><p>O catálogo separa o mapa do recorte da visão de regiões do MVP.</p></div>${sourceLink("Docs/Main/CATALOGS_MVP.md")}</div><div class="table-wrap"><table><thead><tr><th>Região</th><th>Conteúdo documentado</th><th>Escopo</th></tr></thead><tbody>${actualRegionRows}</tbody></table></div><p class="intro-copy">Recursos no layout: ${Object.entries(resourceCounts).map(([id, count]) => `${count} ${prettyId(id, names.items).toLocaleLowerCase("pt-BR")}`).join(" · ")}.</p>`;
  }

  function renderDocs() {
    const docs = data.documentation.map(doc => `<article class="doc-row"><div><strong>${escapeHtml(doc.path.split("/").pop())}</strong><p>${escapeHtml(doc.summary)}</p><code>${escapeHtml(doc.path)}</code></div>${fileLink(doc.path, "abrir ↗")}</article>`).join("");
    const totalPages = Math.max(1, Math.ceil(data.files.length / PAGE_SIZE));
    filePage = Math.max(0, Math.min(filePage, totalPages - 1));
    const pageFiles = data.files.slice(filePage * PAGE_SIZE, (filePage + 1) * PAGE_SIZE);
    const fileRows = pageFiles.map(entry => `<div class="file-row"><span class="file-type">${escapeHtml(entry.extension)}</span>${fileLink(entry.path)}<span class="file-size">${number(entry.size, 0)} B</span></div>`).join("");
    return `${sectionHeader("Documentação", "Fontes principais e índice pesquisável dos arquivos presentes no checkout.", "README.md")}<div class="doc-list">${docs}</div><div class="section-head subhead"><div><h2>Índice de arquivos</h2><p>${number(data.files.length, 0)} caminhos indexados. Use a busca global para filtrar nomes ou conteúdo associado.</p></div></div><div class="file-list">${fileRows}</div><div class="pagination"><button type="button" data-page="prev" ${filePage === 0 ? "disabled" : ""}>← anteriores</button><span>Página ${filePage + 1} / ${totalPages}</span><button type="button" data-page="next" ${filePage + 1 >= totalPages ? "disabled" : ""}>próximos →</button></div>`;
  }

  const renderers = {
    characters: renderCharacters,
    sprites: () => renderAssets(),
    attributes: renderAttributes,
    items: renderItems,
    combat: renderCombat,
    world: renderWorld,
    docs: renderDocs
  };

  function renderSection() {
    titleNode.textContent = names.sections[activeSection];
    sectionRoot.innerHTML = renderers[activeSection]();
    searchResults.hidden = true;
  }

  function searchEntries() {
    const items = [];
    const addCatalog = (rows, label, page, nameMap = {}) => rows.forEach(row => items.push({
      kind: label, title: prettyId(row.id, nameMap), path: "data/catalogs/mvp.json", href: file("data/catalogs/mvp.json")?.href,
      haystack: JSON.stringify(row)
    }));
    addCatalog(data.catalog.characters, "Personagem", "characters", names.characters);
    addCatalog(data.catalog.vocations, "Vocação", "characters", names.vocations);
    addCatalog(data.catalog.weapons_and_tools, "Item", "items", names.items);
    addCatalog(data.catalog.skills, "Habilidade", "combat", names.skills);
    addCatalog(data.catalog.monsters, "Criatura", "world", names.creatures);
    addCatalog(data.catalog.resources, "Recurso", "items", names.items);
    addCatalog(data.catalog.consumables, "Consumível", "items", names.items);
    addCatalog(data.catalog.recipes, "Receita", "items", names.items);
    addCatalog(data.catalog.buildings, "Construção", "items", names.items);
    data.assets.forEach(asset => items.push({ kind: "Sprite / PNG", title: asset.name, path: asset.path, href: asset.href, haystack: `${asset.path} ${asset.status || ""} ${asset.subgroup}` }));
    data.documentation.forEach(doc => items.push({ kind: "Documento", title: doc.path.split("/").pop(), path: doc.path, href: doc.href, haystack: `${doc.path} ${doc.summary}` }));
    data.files.forEach(entry => items.push({ kind: "Arquivo", title: entry.path.split("/").pop(), path: entry.path, href: entry.href, haystack: entry.path }));
    return items;
  }
  const allSearchEntries = () => searchEntries();

  function renderSearch(query) {
    const normalizedQuery = norm(query.trim());
    if (!normalizedQuery) {
      searchResults.hidden = true;
      return;
    }
    const matches = allSearchEntries().filter(entry => norm(`${entry.title} ${entry.path} ${entry.haystack}`).includes(normalizedQuery));
    const displayed = matches.slice(0, 80);
    searchResults.hidden = false;
    searchResults.innerHTML = `<div class="search-heading"><span>${matches.length} resultado${matches.length === 1 ? "" : "s"} para “${escapeHtml(query.trim())}”</span><span>máx. 80 exibidos</span></div>${displayed.length ? `<div class="result-list">${displayed.map(entry => `<a class="result-row" href="${escapeHtml(entry.href || "#")}"><span class="result-kind">${escapeHtml(entry.kind)}</span><span class="result-text"><span class="result-title">${escapeHtml(entry.title)}</span><span class="result-path">${escapeHtml(entry.path)}</span></span></a>`).join("")}</div>` : `<div class="empty-state">Nada encontrado. Tente um ID como <span class="mono">war_combo</span> ou uma pasta como <span class="mono">assets/characters</span>.</div>`}`;
  }

  function openLightbox(button) {
    const dialog = $("#lightbox");
    const href = button.dataset.lightbox;
    const name = button.dataset.title || button.querySelector("img")?.alt || "Prévia do arquivo";
    $("#lightbox-title").textContent = name;
    $("#lightbox-path").textContent = href.replace(/^\.\.\//, "");
    $("#lightbox-image").src = href;
    $("#lightbox-image").alt = name;
    $("#lightbox-open").href = href;
    dialog.showModal();
  }

  nav.addEventListener("click", event => {
    const button = event.target.closest("[data-section]");
    if (!button) return;
    activeSection = button.dataset.section;
    nav.querySelectorAll("[data-section]").forEach(item => {
      const selected = item === button;
      item.classList.toggle("active", selected);
      item.setAttribute("aria-selected", String(selected));
    });
    filePage = 0;
    renderSection();
    searchInput.value = "";
    searchInput.blur();
    sectionRoot.focus({ preventScroll: true });
  });
  searchInput.addEventListener("input", () => renderSearch(searchInput.value));
  document.addEventListener("keydown", event => {
    if (event.key === "/" && !event.ctrlKey && !event.metaKey && !["INPUT", "TEXTAREA"].includes(document.activeElement.tagName)) {
      event.preventDefault(); searchInput.focus();
    } else if (event.key === "Escape" && document.activeElement !== $("#lightbox-close")) {
      searchInput.value = ""; renderSearch("");
    }
  });
  sectionRoot.addEventListener("click", event => {
    const lightboxButton = event.target.closest("[data-lightbox]");
    if (lightboxButton) { openLightbox(lightboxButton); return; }
    const filterButton = event.target.closest("[data-asset-filter]");
    if (filterButton) {
      assetFilter = filterButton.dataset.assetFilter;
      sectionRoot.innerHTML = renderAssets();
      return;
    }
    const pageButton = event.target.closest("[data-page]");
    if (pageButton && !pageButton.disabled) {
      filePage += pageButton.dataset.page === "next" ? 1 : -1;
      sectionRoot.innerHTML = renderDocs();
    }
  });
  $("#lightbox-close").addEventListener("click", () => $("#lightbox").close());
  $("#lightbox").addEventListener("click", event => { if (event.target === $("#lightbox")) $("#lightbox").close(); });

  fetch("./catalog-data.json")
    .then(response => { if (!response.ok) throw new Error(`HTTP ${response.status}`); return response.json(); })
    .then(payload => {
      data = payload;
      renderSection();
    })
    .catch(error => {
      sectionRoot.innerHTML = `<div class="empty-state"><strong>Não foi possível carregar o índice local.</strong><p>Na raiz do repositório, execute <span class="mono">python3 -m http.server 8000</span> e abra <span class="mono">http://localhost:8000/docs/wiki/</span>.</p><small class="mono">${escapeHtml(error.message)}</small></div>`;
    });
})();
