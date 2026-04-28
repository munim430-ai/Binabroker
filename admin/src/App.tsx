import { Building2, ShieldAlert } from 'lucide-react';
import ListingsModeration from './components/ListingsModeration';

export default function App() {
  return (
    <main className="min-h-screen bg-matte text-primaryText">
      <header className="border-b border-border bg-surface/60 backdrop-blur">
        <div className="mx-auto flex max-w-7xl items-center justify-between px-6 py-5">
          <div className="flex items-center gap-3">
            <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-ocean/15 text-ocean">
              <Building2 size={24} />
            </div>
            <div>
              <h1 className="text-xl font-black tracking-tight">BinaBroker Admin</h1>
              <p className="text-sm text-mutedText">Zero-brokerage rental moderation</p>
            </div>
          </div>
          <div className="hidden items-center gap-2 rounded-xl border border-border bg-matte px-4 py-2 text-sm text-mutedText sm:flex">
            <ShieldAlert size={16} />
            Manual MVP Controls
          </div>
        </div>
      </header>

      <section className="mx-auto max-w-7xl px-6 py-8">
        <ListingsModeration />
      </section>
    </main>
  );
}
