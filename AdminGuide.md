# WatchHub — Admin Panel (Next.js)

The staff‑facing admin web app for WatchHub. Manage products, brands, orders,
inventory, reviews, and customer messages. Built with **Next.js 16**,
**React 19**, **Tailwind CSS v4**, and **shadcn/Radix UI** components. Auth and
data come from **Supabase**.

> ⚠️ This project pins **Next.js 16** (React 19, the React Compiler, Tailwind
> v4). APIs and conventions differ from older Next.js — see `AGENTS.md`. Read
> the bundled docs in `node_modules/next/dist/docs/` before changing framework
> code.

---

## Getting started

### Prerequisites

- Node.js 18+
- The same Supabase project used by the backend and mobile app
- An admin user (a `profiles` row with `role = 'admin'`)

### Install & run

```bash
cd admin
npm install
# create .env.local (see below)
npm run dev      # http://localhost:3000
```

Other scripts: `npm run build`, `npm start`, `npm run lint`.

### Environment variables

Create `.env.local`:

```dotenv
NEXT_PUBLIC_SUPABASE_URL=https://<your-project>.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=<anon-key>
```

> The backend's CORS allow‑list already includes `http://localhost:3000`.

---

## Architecture

```
src/
├── app/                      App Router pages
│   ├── login/                Staff login
│   ├── dashboard/            Protected area (requires a signed‑in admin)
│   │   ├── products/         List, new, [id]/edit, inventory,
│   │   │                     best-sellers, new-arrivals
│   │   ├── brands/           List, new, [id]
│   │   ├── orders/           List, invoices, profit-analytics
│   │   └── settings/         billing, notifications, team
│   ├── layout.js             Root layout
│   └── page.js               Entry
├── components/
│   └── ui/                   shadcn/Radix primitives + shared layout
│       └── shared/           app-sidebar, product-table, login-form, …
├── hooks/                    e.g. use-mobile
├── lib/
│   ├── api.js                Calls to the WatchHub backend API
│   ├── auth-client.js        Browser‑side Supabase auth helpers
│   ├── supabase-server.js    Server‑side Supabase client
│   └── utils.js              cn() + helpers
└── proxy.js                  Session refresh + route protection for /dashboard
```

### Auth & route protection

`src/proxy.js` runs on requests, refreshes the Supabase session (so Server
Components can read auth state), and **redirects unauthenticated users away from
`/dashboard`**. Admin role is enforced by the backend on every `/api/admin/*`
call (`requireAdmin`).

### Data flow

- **Reads/writes of business data** go through `lib/api.js` to the
  [backend API](../backend/README.md) (`/api/admin/*`, `/api/products`, etc.).
- **Auth** uses Supabase directly (`auth-client.js` / `supabase-server.js`).
- **Image uploads** go straight to the Supabase `media` bucket via the
  `media-uploader` component using the signed‑in admin's JWT — they do not pass
  through the backend.

---

## Conventions

- UI primitives live in `components/ui/` (shadcn). Compose, don't fork them.
- Tailwind v4 with `tw-animate-css`; class merging via `cn()` in `lib/utils.js`.
- Toasts via `sonner`; icons via `lucide-react`.
