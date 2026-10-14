# Agent working rules

Read `README.md`, `Docs/Main/GDD_MVP.md`, `Docs/Main/CATALOGS_MVP.md`, `Docs/Main/ROADMAP.md`, `docs/technical/ARCHITECTURE.md`, and `Docs/Context/HANDOFF.md` before changing the game. The GDD defines MVP scope; record deviations in `Docs/Context/DECISIONS.md`.

- Work in one small `feature/sNN-name` branch and PR per verifiable increment. Finish the next unchecked roadmap item; avoid unrelated systems and speculative abstractions. Use the simplest cohesive Godot scene/script that meets the current acceptance criterion. Separate camera, movement, world generation and saves by actual responsibility, not by framework fashion.
- Consult official Godot documentation when an engine API or Android behavior is uncertain. Pin the chosen stable Godot version in S0. Keep source-of-truth balance data versioned and validate its IDs.
- Never silently swallow file, network, parsing, or scene failures. Surface a useful message and log enough context without secrets. Add recovery only for a demonstrated failure path.
- Prefer coherent, usable pixel UI and visible gameplay feedback to placeholder layouts. Test controls, scale, zoom, readability, effects and performance on an Android device; editor screenshots alone do not pass a mobile sprint.
- For simple reproducible shapes, UI frames and VFX, use scripted PNG generation (Python/Pillow) in `tools/art/` where helpful; check dimensions, pixel edges and resulting art in Godot. Character/monster concept art is not an animation atlas; verify frame alignment, alpha, pivot and eight directions before integrating.
- Do not commit source photos of children, local saves, keystores, secrets, or credentials. The approved image under `assets/references/` is concept reference only.
- At the end of every session update `Docs/Context/JOURNAL.md` with changes, tests and decisions; replace `Docs/Context/HANDOFF.md` with the exact next action, current branch/commit, blockers and open questions. Update the roadmap checklist and README when behavior changes.

## Protótipo e validação antes de implementar

- Before implementing any MVP phase or material UI/flow change, create and present a visual or navigable prototype for the affected screens, states and transitions. The required process is in `Docs/Main/PROTOTYPING_METHODOLOGY.md`; record version, review and decision in `Docs/Context/PROTOTYPE_LOG.md`.
- Wait for explicit user validation of the prototype before implementing its production UI or dependent flow. If feedback requests changes, revise the prototype and present the new version first. Continue only independent work while validation is pending.
- Prototypes use placeholder data/art and must be clearly labeled as prototypes. They do not count as implemented gameplay, approved production art, Godot import validation, Android validation, or a passed roadmap phase.
- After implementation, compare the running Godot scene with the approved prototype, document intentional deviations, and validate the phase on the target device when the roadmap requires it.
- For visual assets, apply the same gate: prove one representative asset/animation in its target scene and scale, get the requested review, and only then expand to the production batch.

Definition of done: affected tests pass, Godot imports without errors, Android APK is tested for UI/network/save work, the acceptance flow is demonstrated, docs and handoff are current. Do not claim features are implemented when they are only specified.
