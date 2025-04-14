# BLKWDS Manager – Visual Identity Guidelines

## 🎨 Color Palette
| Name              | Hex        | Usage                             |
|-------------------|------------|------------------------------------|
| BLKWDS Green      | `#2F6846`  | App background                     |
| White             | `#FFFFFF`  | Cards, sections, surfaces          |
| Deep Black        | `#1A1A1A`  | Headings, high contrast text       |
| Slate Grey        | `#4D4D4D`  | Secondary text, outlines           |
| Mustard Orange    | `#EBA937`  | Primary CTA buttons, highlights    |
| Electric Mint     | `#60F9A6`  | Success states                     |
| Alert Coral       | `#F35D5D`  | Error states                       |
| Accent Teal       | `#00F0B5`  | Optional accent for focus areas    |

## 🖋 Typography
| Role              | Font      | Style                               |
|-------------------|-----------|--------------------------------------|
| Headings          | Sora      | Bold, geometric, tech/creative vibe  |
| Body Text         | Inter     | Clean, readable, modern              |
| Code/Logs (opt.)  | JetBrains Mono | For activity log screens         |

## 📐 Layout & Spacing
| Element           | Value      |
|-------------------|------------|
| Border Radius     | `16px`     |
| Card Elevation    | `4dp`      |
| Spacing (Small)   | `8px`      |
| Spacing (Medium)  | `16px`     |
| Spacing (Large)   | `24px`     |
| Input Padding     | `16px` horizontal, `12px` vertical |

## 🧩 Components Style
- **Cards**: Rounded corners, white background, subtle shadow
- **Buttons**: Bold mustard orange for primary actions, pill shape, elevation on hover
- **Text Fields**: White fill, soft border, shadow on focus
- **Modals**: Backdrop blur, elevated center panel
- **Icons**: Minimalist line icons, white or black depending on context

## 🧠 Interaction Guidelines
- Use **hover transitions** and **tap feedback** to confirm user input
- Animate transitions lightly (100–200ms ease-in-out)
- Show toast/snackbar for any action feedback (return, checkout, export, etc.)
- Maintain layout consistency by aligning all UI components to an invisible grid

## 🧰 Visual Hierarchy
1. **Accent color (mustard)** draws attention to CTAs
2. **Headings** set context for panels
3. **Cards** group related info, use shadow to separate from background
4. **Whitespace** is a feature, not a gap — let sections breathe

## 📷 Gear Thumbnails
- Optional but encouraged
- Upload via image picker
- Render small preview next to gear name in dashboard
- Save locally and store path in DB (not image blob)

## 🖼 Branding
- Use **colorful logo** version on splash screen and top-left of app
- Avoid logo on every card — keep it clean
- Use stylized "K" mark for loading states or visual cues subtly

---

This system is final and **not to be changed mid-development**.
Everything built should adhere to these principles to avoid UI debt and inconsistency.
