# Nimbus UI

> Preact frontend application for NimbusDrive. Built with Vite (Rolldown-based) and TypeScript.

---

## Tech Stack

- **Preact** ^10.27.2
- **TypeScript** ~5.9.3
- **Vite (Rolldown)** 7.1.14 — Rust-based bundler for fast HMR and builds
- **@preact/preset-vite** ^2.10.2

---

## Scripts

| Command | Description |
|---------|-------------|
| `pnpm dev` | Start development server with HMR |
| `pnpm build` | TypeScript check + production build |
| `pnpm preview` | Preview production build locally |

---

## Quick Start

```bash
pnpm install
pnpm dev
```

The dev server runs on `http://localhost:5173`.

---

## Project Structure

```
nimbus-ui/
├── public/
│   └── vite.svg
├── src/
│   ├── app.tsx
│   ├── app.css
│   ├── main.tsx
│   └── index.css
├── index.html
├── package.json
├── vite.config.ts
├── tsconfig.json
├── tsconfig.app.json
└── tsconfig.node.json
```
