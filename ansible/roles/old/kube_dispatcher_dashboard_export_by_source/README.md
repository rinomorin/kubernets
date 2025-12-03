---

# 🚦 Dispatcher Dashboard (Jinja2 Modular Template)

This role renders a modular, override-ready dashboard for dispatcher-grade exports, sort stack tracking, and compliance visibility. It is structured to support both current Jinja2 rendering and future React migration.

---

## 📁 Directory Structure

```
templates/
├── dashboard_template.j2         # Main wrapper template
├── components/                   # Modular HTML partials
│   ├── header.html
│   ├── table.html
│   ├── footer.html
│   └── legend.html
├── assets/
│   ├── styles/
│   │   └── dashboard.css         # All CSS styles
│   ├── scripts/
│   │   ├── state.js              # Tracks filters, visibility, pagination
│   │   ├── sort.js               # Sort logic + keyboard shortcuts
│   │   ├── export.js             # CSV/JSON export with metadata
│   │   └── ui.js                 # ARIA, tooltips, sort icons
│   └── icons/                    # Optional SVGs or images
```

---

## 🧩 Component Overview

### `dashboard_template.j2`
- Main HTML wrapper
- Loads all components and assets
- Jinja2-compatible and override-ready

### `components/header.html`
- Dashboard title and control buttons
- Includes:
  - 🧹 Clear Sort
  - 🔁 Restore Last Sort
  - 📤 Export CSV / JSON
- Contains ARIA live region for accessibility

### `components/table.html`
- Dynamic table with:
  - Jinja2 loop over `columns` and `rows`
  - Sortable headers with icons and keyboard shortcut hints
- Mirrors React-style props: `columns[]`, `rows[]`

### `components/footer.html`
- Displays:
  - Export timestamp
  - Dashboard title, user ID, and role
- Metadata is injected via Jinja2

### `components/legend.html`
- Explains:
  - Sort icons (↑ / ↓)
  - Keyboard shortcuts:
    - `Alt+N` → ascending
    - `Shift+Alt+N` → descending
    - `Ctrl+Alt+N` → secondary sort stack

---

## 🧠 Script Responsibilities

### `scripts/state.js`
- Tracks:
  - Filter values (`data-filter`)
  - Section visibility (`data-section`)
  - Pagination state (`data-page`, `data-page-size`)
- Used by `export.js` to inject metadata

### `scripts/sort.js`
- Handles:
  - `sortTable(n, direction)`
  - `addSecondarySort(n)`
  - `clearSort()`, `restoreLastSort()`
- Keyboard shortcuts:
  - `Alt+N` → ascending
  - `Shift+Alt+N` → descending
  - `Ctrl+Alt+N` → add to sort stack

### `scripts/export.js`
- Exports table as:
  - CSV with metadata block
  - JSON with structured `data` and `metadata`
- Metadata includes:
  - Sort stack
  - Filters
  - Visibility
  - Pagination
  - Timestamp

### `scripts/ui.js`
- Handles:
  - ARIA announcements
  - Sort icon rendering (↑ / ↓)
  - Tooltip and `aria-label` updates
  - Focus styles for keyboard navigation

---

## 🧪 Testing & Override Strategy

- Override any component via `templates/components/*.html`
- Override styles or scripts via `assets/`
- Use `ansible-playbook` with `template:` to render `dashboard_template.j2`

---

## 🔄 React Migration Ready

This structure is designed to be React-importable:

- `columns[]` and `rows[]` mimic props
- HTML partials can be converted to `.jsx` with minimal changes
- Scripts can be modularized into hooks or context providers

---

## 📋 Metadata Injection (for audit/export)

All exports include:

```json
{
  "exported_at": "2025-11-04T23:32:00Z",
  "dashboard_title": "Promotion Source Dashboard",
  "sort_stack": [
    { "index": 2, "name": "Promotion Source", "direction": "ascending" }
  ],
  "filters": { "role": "web", "source": "internal" },
  "visibility": { "legend": true, "footer": true },
  "pagination": { "current_page": 1, "page_size": 25 }
}
```

---

## 🛠️ Future Enhancements

- Add filter controls with `data-filter`
- Add pagination controls with `data-page`
- Add section toggles with `data-section`
- Add export presets (e.g. filtered only, visible only)

---
