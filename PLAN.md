# Dendritic migration plan

Status: implementation completed in commit `d3d170a`; see the implementation
notes at the end for completed scope and deferred work.

## Goal

Keep the root `flake.nix` as the input declaration and a minimal
`flake-parts.lib.mkFlake` entry point importing `(inputs.import-tree ./modules)`.
Move repository-owned Nix implementation into `modules/`, with each discovered
Nix file declaring flake-parts configuration. Explicitly imported `_*.nix`
helpers are allowed and excluded from auto-discovery. Migrate incrementally, checking
behavior after each step rather than moving everything at once.

Preserve existing outputs and package behavior. This is a structural refactor,
not a dependency update, package repair, or feature cleanup.

## Current inventory and affected consumers

There are 61 tracked Nix files:

- `flake.nix`: inputs, overlay composition, external module imports, systems,
  exported hook modules, templates, and diagnostic outputs.
- `per-system.nix`: already a flake-parts module; explicitly imports `nix/tests`.
- `nix/actions-nix.nix` and `nix/tests/default.nix`: already flake-parts modules.
- `flakeModules/pre-commit-custom.nix`: already module-shaped, but exported via
  `importApply` with this repository's inputs captured. Both
  `custom-pre-commit-hooks` and `custom-git-hooks` are public aliases.
- `overlays/default.nix`: input-parameterized overlay; combines inline overrides,
  recursive package discovery, Python extensions, Haskell overrides, and Nixvim.
- `overlays/packages/` and `overlays/python-packages/`: package functions, not
  flake-parts modules. Recursive discovery must keep working during migration.
- `overlays/custom-packages/`: package helpers, Nixvim configuration and plugins,
  plus Lua/snippet/script assets.
- `templates/basic/`: a standalone flake and its per-system module, not modules
  that can be imported directly into the parent flake.

Affected interfaces include `overlays.default`, `overlays.utils`, `packages`,
`legacyPackages`, `checks`, `devShells`, `formatter`, both exported hook aliases,
`templates.default`, `nixosModules`, `flakePartsConfig`, and `self`. Also inspect
outputs supplied by actions-nix and treefmt rather than assuming this list is
exhaustive.

Relative paths needing attention include package scripts and patches, Nixvim
Lua/snippets/plugins, the template export, and the `template-check` script's
`${./..}` reference to the repository root. CI and generated pre-commit files
must continue to refer to valid outputs and paths.

## Confirmed decisions

1. **Helpers allowed:** auto-discovered files must be flake-parts modules, but
   package functions and nested modules may remain explicitly imported `_*.nix`
   helpers under `modules/`. Prefer this where it avoids unnecessary registration
   machinery. Verify the pinned import-tree's exclusion behavior before use.
2. **Template exception:** keep `templates/basic/` outside the root module tree.
   Migrate its configuration to `templates/basic/modules/` and give its standalone
   `flake.nix` its own import-tree wiring.
3. **Output compatibility only:** preserve public flake output names and
   behavior. Remove old source paths after migrating internal callers; no
   compatibility shims for external direct source imports.
4. **Full validation:** evaluate incrementally, then attempt a full
   `nix flake check` plus downstream hook and generated-template smoke tests.
   Record pre-existing failures and environmental blockers explicitly.
5. **Execution authorized:** implementation was carried out after the user
   requested it; the original plan-only instruction was superseded.

## Phase 0 — Baseline before edits

- Record the starting revision and working-tree state; it is clean before this
  plan is added.
- Read each file fully before migrating it and trace its callers and assets.
- Run `nix flake check --no-build` and inventory output names and evaluable
  derivation paths on the existing `x86_64-linux` system.
- Inspect representative ordinary packages, Python packages, Haskell packages,
  Nixvim, hook modules, development shell, formatter, and template consumers.
- Record pre-existing failures separately. For example, the overlay references
  `inputs.nixpkgs-unstable`, and the PETSc helper references
  `inputs.nixpkgs-2505`, neither declared by the root flake. Laziness may keep
  these dormant; the refactor must not accidentally force or silently repair
  them.
- Save baseline observations outside exported source assets. Compare derivation
  paths where meaningful, but investigate differences rather than demanding
  universal equality: several outputs embed the repository source path, which
  necessarily changes during a move.

## Phase 1 — Introduce import-tree and move existing modules

1. Add a direct `import-tree` input and lock it without updating unrelated inputs.
2. Create `modules/` and add `(inputs.import-tree ./modules)` to the current
   flake-parts imports while leaving unmigrated wiring intact.
3. Move `nix/tests/default.nix` to `modules/tests/default.nix`; remove the explicit
   tests import from `per-system.nix` in the same step. Evaluate.
4. Move `per-system.nix` to `modules/per-system.nix`; remove its old root import.
   Evaluate.
5. Move `nix/actions-nix.nix` to `modules/actions-nix.nix`; remove its old import.
   Keep the external actions-nix module imported exactly once. Evaluate.
6. Run the existing Pandoc check and focused tooling checks before proceeding.

No moved module should be imported both explicitly and through import-tree.
Stage new files before flake evaluation so Git-based source filtering includes
those files. Commit the validated phase.

## Phase 2 — Move root wiring and reusable module exports

- Move systems, external module imports, template export, and remaining flake
  output wiring into small topic modules under `modules/`.
- Convert the hook file into an auto-imported module that defines the reusable
  hook module and exports both existing aliases. Apply the same module locally.
  Preserve capture of nix-extra's own inputs when downstream consumers import
  these exports; do not accidentally substitute a consumer's `inputs`.
- Move overlay composition into a flake-parts module, initially retaining the
  explicit import of the old overlay implementation as a transitional bridge.
- Preserve the exact overlay order, including the current repeated use of the
  local overlay through `overlays.utils`; changing it is outside this refactor.
- Reduce root outputs to `mkFlake` plus import-tree once its remaining definitions
  have moved. Remove the single-element recursive-update fold if redundant.
- Validate exported hooks in a minimal downstream flake as well as locally.

## Phase 3 — Convert overlay and package files one at a time

For each source file:

1. Copy it into its destination topic under `modules/`, together with any local
   non-Nix assets whose relative paths should be retained.
2. Edit that one file into a flake-parts module, retaining the original package
   function or nested module body inside the configuration it contributes.
   Alternatively retain it as an excluded `_*.nix` helper and register it from
   an auto-imported topic module; use this simpler route where appropriate.
3. Connect the contribution to the existing overlay/package set and remove its
   old registration. Ensure the old discovery mechanism does not also register
   the migrated package.
4. Evaluate the affected output and its relevant consumers; build a focused
   representative when feasible and compare with the baseline.
5. Remove the obsolete source and obsolete relative imports after validation.
   Commit small coherent steps, with no permanently duplicated implementation.

Implementation constraints:

- Use a small typed internal module option only where needed to merge package
  definitions or overlay contributions. Prefer existing flake-parts facilities
  if they preserve behavior; do not create a general framework.
- Preserve `prev.callPackage` versus `final.callPackage` semantics. Separately
  composed overlay stages change what `prev` means, so do not replace the
  original single-overlay merge with an arbitrary sorted overlay list.
- Keep Python contributions inside `pythonPackagesExtensions` and preserve
  Python's own `callPackage` scope and overrides.
- Keep Haskell contributions inside the existing Haskell package-set override.
- Preserve discovery-derived attribute names, including nested attributes,
  explicit overrides, and precedence between inline and discovered definitions.
- Move currently unused definitions too, without enabling them. In particular,
  the commented-out Nixvim `gp.nix` and `cmp.nix` plugins must remain inactive.
  They can be excluded helpers, or inactive definitions inside auto-imported
  flake-parts wrappers.
- Do not expose every migrated package as a new top-level flake package; keep
  the existing distinction between overlay/legacy packages and explicit exports.

Suggested migration order: ordinary packages, Python packages, custom package
helpers, Haskell overrides, Nixvim configuration/plugins, then remaining inline
adjustments in `overlays/default.nix`. Remove recursive discovery and the legacy
bridge only after their last consumer has migrated.

## Phase 4 — Template, assets, and cleanup

- Apply the agreed template arrangement and retain `templates.default` behavior.
- If migrating the template itself, make its `import-tree` input follow the
  nix-extra input consistently with its existing flake-parts/nixpkgs follows.
- Update all moved asset references, especially `template-check` so it still
  targets the root flake rather than the module directory.
- Test template generation in a temporary directory, overriding its nix-extra
  input to the working repository so the test cannot silently use upstream.
- Remove empty legacy directories and search for remaining old path references.
- Update `README.rst` with the module layout and how to add a package/module.
- Regenerate tracked tooling configuration only where required and inspect the
  diff; avoid unrelated formatting or workflow changes.

## Validation and completion criteria

At each step:

- Parse/format the changed Nix files and run evaluation of the affected outputs.
- Run `nix flake check --no-build` at phase boundaries and compare failures to the
  baseline. Run independent targeted checks in parallel where useful.
- Check that new modules are auto-discovered and no migrated file is still
  manually imported as a top-level flake-parts module.
- Check output names, aliases, overlay behavior, and moved asset paths.

At completion:

- Root `flake.nix` contains inputs, description, and minimal import-tree wiring.
- All implementation Nix files are under `modules/` and follow the agreed
  auto-import rule; only explicitly agreed template/helper exceptions remain.
- No legacy imports or recursive package discovery remain for converted files.
- Existing public outputs and inactive configurations are preserved.
- Run `nix flake check`, plus downstream hook-module and generated-template smoke
  tests. Full checks include all exported packages because `per-system.nix`
  assigns packages to checks.
- Build the default dev shell and Nixvim; exercise
  both hook aliases and representative Python/ordinary overlay packages.
- Add a small regression check for any new nontrivial registration/merge logic,
  covering discovery, names, and precedence. Do not add a test framework.
- Review `git diff --check`, lockfile changes, source layout, generated files,
  and the final output inventory; commit each validated migration phase.
- Report successful commands, baseline failures, new blockers, and anything not
  built. An evaluation-only run must not be reported as proof all builds work.

## Implementation notes

Completed in commit `d3d170a`:

- Added the pinned import-tree input and reduced root `flake.nix` to input
  declarations plus import-tree wiring.
- Moved flake-parts modules to `modules/`; moved overlay/package source trees
  beneath excluded `modules/_overlays/` helpers, preserving their relative asset
  layout and the existing recursive package discovery and overlay behavior.
- Added auto-imported core, hooks, and overlay flake-parts modules; retained both
  hook export aliases and the original overlay composition order.
- Moved the template per-system module to `templates/basic/modules/` and added
  its own import-tree wiring. Updated its deprecated removed `nixfmt-rfc-style`
  hook to `nixfmt` so the template evaluates with the currently locked hooks.
- Updated the README and corrected `template-check`'s repository-root path.

Validation completed:

- Baseline and final `nix flake check --no-build` passed.
- Final full `nix flake check` built and passed all 48 checks, including
  `treefmt`, pre-commit, and the Pandoc check.
- Built the dev shell, template-check derivation, backupper/doit-ext, and Nixvim
  (also covered by the full check).
- Generated the template using a local nix-extra override; its flake check and
  dev-shell build passed.
- A minimal downstream flake importing `custom-git-hooks` evaluated its
  pre-commit derivation successfully.
- Formatting and commit hooks passed; working tree was clean after commit.

Deferred from the more ambitious per-package dendritic conversion in Phase 3:
package functions remain explicitly imported helpers under `modules/_overlays/`
with their original package-discovery implementation. This uses the approved
`_*.nix` helper exception and avoids changing overlay scope, precedence, or the
Python/Haskell package-set semantics in this structural move. If the requirement
is that each package file itself contributes a flake-parts definition, that is a
separate follow-up migration. The template's `nixfmt` hook rename was necessary
for its full smoke test, but is a small compatibility adjustment beyond a pure
move.

## Out of scope

Dependency upgrades beyond adding import-tree, package fixes unrelated to moved
code, activating disabled packages/plugins, output renames, changing supported
systems, and redesigning editor or hook behavior.
