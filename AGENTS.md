# Agent working rules

Read `README.md`, `Docs/Main/GDD_MVP.md`, `Docs/Main/CONTENT_DATA.md`, `Docs/Main/ROADMAP.md`, `docs/technical/ARCHITECTURE.md`, and `Docs/Context/HANDOFF.md` before changing the game. The GDD defines MVP scope; record deviations in `Docs/Context/DECISIONS.md`.

- Work in one small `feature/sNN-name` branch and PR per verifiable increment. Finish the next unchecked roadmap item; avoid unrelated systems and speculative abstractions. Use the simplest cohesive Godot scene/script that meets the current acceptance criterion. Separate camera, movement, world generation and saves by actual responsibility, not by framework fashion.
- Consult official Godot documentation when an engine API or Android behavior is uncertain. Pin the chosen stable Godot version in S0. Keep source-of-truth balance data versioned and validate its IDs.
- Never silently swallow file, network, parsing, or scene failures. Surface a useful message and log enough context without secrets. Add recovery only for a demonstrated failure path.
- Prefer coherent, usable pixel UI and visible gameplay feedback to placeholder layouts. Test controls, scale, zoom, readability, effects and performance on an Android device; editor screenshots alone do not pass a mobile sprint.
- For simple reproducible shapes, UI frames and VFX, use scripted PNG generation (Python/Pillow) in `tools/art/` where helpful; check dimensions, pixel edges and resulting art in Godot. Character/monster concept art is not an animation atlas; verify frame alignment, alpha, pivot and eight directions before integrating.
- Do not commit source photos of children, local saves, keystores, secrets, or credentials. The approved image under `assets/references/` is concept reference only.
- At the end of every session update `Docs/Context/JOURNAL.md` with changes, tests and decisions; replace `Docs/Context/HANDOFF.md` with the exact next action, current branch/commit, blockers and open questions. Update the roadmap checklist and README when behavior changes.

Definition of done: affected tests pass, Godot imports without errors, Android APK is tested for UI/network/save work, the acceptance flow is demonstrated, docs and handoff are current. Do not claim features are implemented when they are only specified.
