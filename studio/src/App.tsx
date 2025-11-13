import { ConfigPanel } from './components/layout/ConfigPanel';
import { Header } from './components/layout/Header';
import { TimelineView } from './components/timeline/TimelineView';
import { StatsPanel } from './components/stats/StatsPanel';
import { AnswerSetGrid } from './components/consistent/AnswerSetGrid';
import { useCasperData } from './hooks/useCasperData';

export default function App() {
  const { mode } = useCasperData();

  return (
    <div className="app-shell">
      <Header />
      <main>
        <section className="panel">
          <ConfigPanel />
        </section>

        {mode === 'consistent' && (
          <section className="panel">
            <AnswerSetGrid />
          </section>
        )}

        <section className="panel">
          <TimelineView />
        </section>

        <section className="panel">
          <StatsPanel />
        </section>
      </main>
    </div>
  );
}
