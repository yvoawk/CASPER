import { ModeSelector } from '../common/ModeSelector';

export const Header = () => (
  <header style={{ padding: '1.5rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
    <div>
      <h1 style={{ margin: 0 }}>CASPER Studio</h1>
      <p style={{ margin: 0, color: 'var(--text-muted)' }}>Visualize ASP-inferred clinical timelines</p>
    </div>
    <ModeSelector />
  </header>
);
