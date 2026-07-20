# IncaCook — contributor notes

## Agent skills

### Issue tracker

GitHub Issues; external PRs are not a triage surface. See
`docs/agents/issue-tracker.md`.

### Triage labels

Use `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, and
`wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout using root `CONTEXT.md` and `docs/adr/`. See
`docs/agents/domain.md`.

## Theming

The app fully supports light + dark mode via `ThemeMode.system`/`light`/`dark`,
selectable from **Settings → Apparence** and persisted with `GetStorage`.
The migration off the old `AppColors` constants is complete — the file
`lib/core/constants/colors.dart` no longer exists.

### Where colors live

| Layer | Location | When to use |
|---|---|---|
| Brand-stable | `lib/core/utils/theme/brand_colors.dart` | `BrandColors.primary`, `secondary`, `success`, `warning`, `error`, `info`. Same hex in both modes. |
| Mode-variant raw | `lib/core/utils/theme/palette.dart` (`LightPalette` / `DarkPalette`) | **Only inside theme config**. Never read these from a widget. |
| Material tokens | `Theme.of(context).colorScheme.X` | Default surface / on-surface / outline / etc. The 90% case for widgets. |
| Project-specific | `context.appColors.X` | `frostedTint`, `decorBlobTint`, `selectedSurface`, `selectedOnSurface`, `barrierOverlay`. Defined in `lib/core/utils/theme/theme_extensions.dart`. |

### Conventions

- **Never reach for raw hex literals** in widgets except for genuinely
  semantic colors (per-criterion rating accents, dietary tag colors, alert
  badge red). Add a comment explaining why if you do.
- **Drop `.copyWith(color: …)` overrides** when the theme's `textTheme` already
  provides the right `onSurface`. Smaller diff, adapts automatically.
- **Use `context.isDark`** rather than
  `Theme.of(context).brightness == Brightness.dark`. The extension is in
  `theme_extensions.dart` alongside `appColors`.
- **For "selected" pills/chips/buttons** (filter button, category pill,
  nav menu, etc.), the bg + fg pair is `colors.selectedSurface` +
  `colors.selectedOnSurface` (where `final colors = context.appColors;`).
- **For frosted surfaces**, prefer the `FrostedSurface` widget
  (`lib/core/widgets/effects/frosted_surface.dart`) — its tint and border are
  already theme-driven.
- **For modal sheets**, prefer `showBlurredModalBottomSheet`
  (`lib/core/utils/popups/blurred_modal_sheet.dart`) — frosted backdrop,
  theme-aware barrier overlay.
- **Use `withValues(alpha:)`** instead of the deprecated `withOpacity()`.

### Adding new mode-variant tokens

If a color genuinely needs to differ between light and dark and doesn't fit
Material's `ColorScheme`:
1. Add the field to `AppColorExtensions` (constructor + `copyWith` + `lerp`).
2. Provide light/dark values in the `.light()` / `.dark()` factories.
3. Read it from widgets via `context.appColors.<yourField>`.

Don't add it to `BrandColors` (which is mode-stable) or `LightPalette` /
`DarkPalette` (which are theme-config-only).

### When in doubt

Pick a Material `ColorScheme` token first. If nothing fits, extend
`AppColorExtensions`. Never reintroduce a flat `AppColors`-style
constant file.
