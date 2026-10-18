#!/usr/bin/env python3
"""Refresh the bestiary reference tables and status notes from the game catalog."""

from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CATALOG = ROOT / "data/catalogs/mvp.json"


def replace_between(text: str, start: str, end: str, replacement: str) -> str:
    left = text.index(start)
    if not end:
        return text[:left] + replacement
    right = text.index(end, left)
    return text[:left] + replacement + text[right:]


def main() -> None:
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    regions = {entry["id"]: entry.get("name", entry["id"]) for entry in catalog["regions"]}
    behavior_names = {
        "skittish": "foge; revida se atacada",
        "flee_only": "foge; não ataca",
        "aggressive": "agressivo; persegue e ataca",
    }
    catalog_rows = [
        "| ID / nome | Região | HP / ataque | Comportamento | XP | Drops |",
        "|---|---|---:|---|---:|---|",
    ]
    content_rows = [
        "| Nome / ID | Região | HP | Ataque | Comportamento | XP | Drops | Sprite estático |",
        "|---|---|---:|---:|---|---:|---|---|",
    ]
    expansion_rows = [
        "| # | Nome | Região | HP | Dano / golpe | Sprite estático |",
        "|---:|---|---|---:|---:|---|",
    ]
    for index, monster in enumerate(catalog["monsters"], 1):
        drops = []
        for drop in monster["drops"]:
            chance = f" ({round(drop['chance'] * 100)}%)" if drop.get("chance", 1) < 1 else ""
            drops.append(f"{drop['quantity']} {drop['item'].replace('_', ' ')}{chance}")
        loot = "; ".join(drops) if drops else "sem loot definido"
        region = regions[monster["region"]]
        behavior = behavior_names.get(monster.get("behavior", "aggressive"), "agressivo")
        catalog_rows.append(
            f"| `{monster['id']}` · {monster['name']} | {region} | "
            f"{monster['hp']}/{monster['attack']} | {behavior} | {monster['xp']} | {loot} |"
        )
        content_rows.append(
            f"| {monster['name']} (`{monster['id']}`) | {region} | {monster['hp']} | "
            f"{monster['attack']} | {behavior} | {monster['xp']} | {loot} | "
            f"[`PNG`](../../{monster['sprite_path']}) · pose SE |"
        )
        expansion_rows.append(
            f"| {index} | {monster['name']} (`{monster['id']}`) | {region} | {monster['hp']} | "
            f"{monster['attack']} | [`PNG`](../../../{monster['sprite_path']}) · pose SE |"
        )

    path = ROOT / "Docs/Main/CATALOGS_MVP.md"
    text = path.read_text(encoding="utf-8")
    table = "## 5. Bestiário\n\n" + "\n".join(catalog_rows) + "\n"
    text = replace_between(text, "## 5. Bestiário", "\nSem boss ou escalonamento", table)
    text = text.replace(
        "Sem boss ou escalonamento automático pelo nível do jogador. Host decide drop uma vez, e respawn ocorre fora da visão e da proteção, com população limitada por chunk.",
        "Sem boss ou escalonamento automático pelo nível do jogador. O layout atual tem 57 pontos de spawn distribuídos por seis regiões nomeadas; a lagoa, as ruínas e as terras corrompidas são zonas lógicas sobre o terreno atual, sem cenário próprio. Host decide drop uma vez, e respawn ocorre fora da visão e da proteção, com população limitada por chunk.",
    )
    path.write_text(text, encoding="utf-8")

    path = ROOT / "Docs/art/candidates/BESTIARY_STATIC_CONCEPTS_30_V0_1.md"
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    header_index = next(i for i, line in enumerate(lines) if line.startswith("| Posição | Nome |"))
    if "Sprite individual" not in lines[header_index]:
        lines[header_index] = lines[header_index][:-1] + "| Sprite individual |"
        lines[header_index + 1] = lines[header_index + 1][:-1] + "|---|"
        for index, monster in enumerate(catalog["monsters"], 1):
            row_index = header_index + 1 + index
            lines[row_index] = (
                lines[row_index][:-1]
                + f"| [`PNG`](../../../{monster['sprite_path']}) |"
            )
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")

    path = ROOT / "Docs/art/candidates/BESTIARY_EXPANSION_30_V0_2.md"
    text = path.read_text(encoding="utf-8")
    old_expansion_table = "| # | Nome | Região | HP | Dano | Sprite-base gratuito proposto |"
    new_expansion_table = "| # | Nome | Região | HP | Dano / golpe | Sprite estático |"
    if old_expansion_table in text:
        text = replace_between(
            text,
            old_expansion_table,
            "\n## Pesquisa de sprites",
            "\n".join(expansion_rows) + "\n\n",
        )
    elif new_expansion_table not in text:
        raise SystemExit("Expansion table not found")
    text = text.replace("](" + "../../assets/creatures/", "](" + "../../../assets/creatures/")
    path.write_text(text, encoding="utf-8")

    path = ROOT / "Docs/Main/CONTENT_DATA.md"
    text = path.read_text(encoding="utf-8")
    table = "## Bestiário e drops\n\n" + "\n".join(content_rows) + "\n\n"
    text = replace_between(text, "## Bestiário e drops", "\n## XP e árvore", table)
    text = text.replace(
        "Desaparecer/reaparecer fora da visão do jogador com limite de população por chunk; sem spawn no perímetro protegido, sem enxame e sem boss. Defesa, intervalo de ataque, raio e crescimento por região aguardam playtest. Monstros não escalam automaticamente com o nível do jogador: variantes futuras são ligadas a regiões/expansões. Drops são decididos pelo host; uma morte de monstro gera exatamente um evento de recompensa.",
        "O catálogo tem 30 espécies, 27 novas em relação ao recorte anterior. HP, ataque e XP das novas fichas são valores provisórios para playtest; nenhuma criatura nova tem loot configurado. Cada PNG é uma pose estática SE de 229×229 px, derivada de conceito original, com escala e pivô em metadata. O jogo ainda não tem poses em outras direções nem animações para este lote. Desaparecer/reaparecer fora da visão do jogador, limite de população por chunk, refúgio sem spawn e morte com uma recompensa permanecem regras do recorte.",
    )
    text = text.replace(
        "XP de monstro integral aos participantes próximos e ativos, nunca duplicado na rede.",
        "XP de monstro integral aos participantes próximos e ativos, nunca duplicado na rede. A faixa original continua Raposa/Lobo/Urso = 10/20/50; as 27 fichas novas usam 10/20/50 por faixas de HP somente como valores iniciais de playtest.",
    )
    path.write_text(text, encoding="utf-8")

    path = ROOT / "Docs/Main/GDD_MVP.md"
    text = path.read_text(encoding="utf-8")
    old = "No MVP: quatro aparências, três vocações, uma arma inicial e uma melhora por vocação, três habilidades ativas por vocação, raposa/lobo/urso, árvore parcial e nível máximo 10, solo e dois jogadores Wi-Fi local. NPCs coletores, novos monstros, outros biomas, castelo, Vael boss, construção livre e desktop são expansões."
    new = "No MVP: quatro aparências, três vocações, uma arma inicial e uma melhora por vocação, três habilidades ativas por vocação, bestiário de 30 espécies em poses estáticas, árvore parcial e nível máximo 10, solo e dois jogadores Wi-Fi local. Os valores das 27 espécies adicionadas, seus drops, IA e equilíbrio ainda são provisórios. Lagoa cristalina, ruínas de obsidiana e terras corrompidas são zonas lógicas sobre o mapa atual e ainda não têm terreno ou props próprios. NPCs coletores, castelo jogável, Vael boss, construção livre e desktop continuam expansões."
    if old in text:
        text = text.replace(old, new)
    elif new not in text:
        raise SystemExit("GDD scope sentence not found")
    path.write_text(text, encoding="utf-8")

    path = ROOT / "Docs/Main/ROADMAP.md"
    text = path.read_text(encoding="utf-8")
    section = """### Bestiário estático de 30 espécies — 2026-10-18

- [x] Catálogo com 30 fichas, valores provisórios, nomes, regiões lógicas e caminhos de sprites.
- [x] Cortar as 30 células da prancha em PNG RGBA individuais de 229×229; adicionar metadata estática SE, pivô, escala e footprint alpha.
- [x] Distribuir 57 slots no layout em seis regiões, incluindo as 27 espécies novas; nenhum ponto está em obstáculo, recurso, água, refúgio ou chunk acima do limite atual de dois.
- [x] Usar cena base como fallback para as espécies novas; IA segue o comportamento de cada ficha; Corça de Musgo só foge.
- [x] Atualizar protótipo navegável, tabela de conteúdo e wiki offline.
- [ ] Importar e abrir no Godot 4.5.1; conferir escala, pivôs, alpha e combate com pelo menos uma espécie pequena, média e grande. Esta checagem no editor é necessária antes de considerar a arte aprovada.
- [ ] Playtestar os valores provisórios, as seis regiões e loot/XP; as zonas lógicas ainda não alteram o terreno ou os props atuais.
- [ ] Produzir direções e animações para o jogo final. Este lote tem apenas uma pose estática SE por criatura.
"""
    old_roadmap_heading = "### Proposta de bestiário de expansão"
    new_roadmap_heading = "### Bestiário estático de 30 espécies — 2026-10-18"
    if old_roadmap_heading in text:
        text = replace_between(text, old_roadmap_heading, "\n### Cenas herdadas de criatura", section)
    elif new_roadmap_heading not in text:
        raise SystemExit("Bestiary roadmap section not found")
    path.write_text(text, encoding="utf-8")

    path = ROOT / "Docs/art/candidates/BESTIARY_STATIC_CONCEPTS_30_V0_1.md"
    text = path.read_text(encoding="utf-8")
    text = text.replace(
        "**Estado:** concept art para revisão. A imagem mostra 30 poses estáticas em grade de 5 colunas × 6 linhas, na ordem da tabela abaixo. Não contém animações e ainda não é um atlas de produção.",
        "**Estado:** conceito estático recortado em 30 prévias individuais de runtime. A imagem permanece preservada como fonte e as fichas/paths são listados abaixo. Cada saída é uma célula RGBA de 229×229 px, sem redimensionamento ou alteração do alpha; metadata registra pivô, escala, footprint e a única pose SE. Não há animações nem aprovação de arte final.",
    )
    text = text.replace(
        "A amostra possui pixels semitransparentes; recortes e limpeza de borda continuam necessários antes de usar cada pose como sprite separado.",
        "As bordas semitransparentes da prancha foram preservadas nos recortes; inspeção manual de halos/alpha e revisão de legibilidade no Godot continuam pendentes.",
    )
    text = text.replace(
        "Os valores repetem a proposta em [BESTIARY_EXPANSION_30_V0_2.md](BESTIARY_EXPANSION_30_V0_2.md); não foram adicionados ao catálogo nem balanceados em jogo. A prancha foi gerada como imagem original para este concept, usando as referências visuais do projeto. Nenhuma arte dos pacotes gratuitos pesquisados foi incorporada nela; as fontes CC0 e as diferenças de escala continuam descritas na proposta de expansão.",
        "Os valores repetem a proposta em [BESTIARY_EXPANSION_30_V0_2.md](BESTIARY_EXPANSION_30_V0_2.md) e agora estão integrados ao catálogo como provisórios. A prancha foi gerada como imagem original para este concept, usando as referências visuais do projeto. Nenhuma arte dos pacotes gratuitos pesquisados foi incorporada nela; as fontes CC0 continuam registradas como alternativas pesquisadas.",
    )
    text = replace_between(
        text,
        "## Próxima validação",
        "",
        "## Arquivos individuais\n\nO script reproduzível [`slice_bestiary_static_concepts.py`](../../../tools/art/slice_bestiary_static_concepts.py) corta na ordem do catálogo. Cada ficha tem PNG e JSON em `assets/creatures/<id>/`; a coluna Sprite em [`CONTENT_DATA.md`](../../Main/CONTENT_DATA.md) aponta para cada pose.\n\n## Próxima validação\n\nAbrir no Godot e revisar uma espécie pequena, uma média e uma grande, conferindo tamanho, pivô, alpha, contato e leitura no mundo 2.5D. Os sprites permanecem prévias estáticas conceituais até essa revisão.\n",
    )
    path.write_text(text, encoding="utf-8")

    path = ROOT / "Docs/art/candidates/BESTIARY_EXPANSION_30_V0_2.md"
    text = path.read_text(encoding="utf-8")
    text = text.replace(
        "**Estado: em validação; conteúdo, números e sprites ainda não foram integrados ao catálogo de produção.** A proposta tem 30 fichas no total: as 3 criaturas atuais e 27 novas entradas/variantes. Os valores são iniciais para playtest. Dano significa dano por golpe, não DPS; a Corça de Musgo foge e não ataca.",
        "**Estado: integrado como conteúdo provisório e prévia estática, a pedido do usuário.** São 30 fichas totais: as três espécies originais e 27 novas entradas/variantes. Números permanecem para playtest; dano significa por golpe, não DPS. A Corça de Musgo foge e não ataca. Cada linha usa o recorte PNG no caminho em `data/catalogs/mvp.json`; a arte não é final nem animada.",
    )
    integration_note = "## Estado da integração\n\nO catálogo agora contém 30 espécies e o mapa tem 57 slots distribuídos em seis regiões lógicas. A prancha conceitual foi recortada em PNG individuais de 229×229 com metadata de pivô, escala e footprint alpha; somente pose SE estática está disponível. O jogo usa uma cena base para as espécies sem cena própria e não inventa animações.\n\nOs packs grátis pesquisados acima foram avaliados como referências, mas não foram incorporados. As imagens atuais são conceitos originais do projeto. HP, dano, XP das novas fichas, IA, loot e posicionamento regional ainda precisam de playtest. A lagoa, as ruínas e as terras corrompidas são rótulos de distribuição; a arte do terreno não foi alterada.\n"
    if "## Escopo desta proposta" in text:
        text = replace_between(text, "## Escopo desta proposta", "", integration_note)
    elif "## Estado da integração" not in text:
        raise SystemExit("Bestiary integration note not found")
    path.write_text(text, encoding="utf-8")

    print("Tabelas e documentação do bestiário atualizadas.")


if __name__ == "__main__":
    main()

