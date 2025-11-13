import { CasperMode } from '../../types/casper';
import { useCasperData } from '../../hooks/useCasperData';

const MODES: Array<{ label: string; value: CasperMode }> = [
  { label: 'Naive', value: 'naive' },
  { label: 'Consistent', value: 'consistent' },
  { label: 'Preferred', value: 'preferred' },
  { label: 'Cautious', value: 'cautious' }
];

export const ModeSelector = () => {
  const { mode, setMode } = useCasperData();
  return (
    <div className="mode-selector" role="tablist" aria-label="Timeline mode selector">
      {MODES.map((item) => (
        <button
          type="button"
          key={item.value}
          className={item.value === mode ? 'active' : ''}
          onClick={() => setMode(item.value)}
        >
          {item.label}
        </button>
      ))}
    </div>
  );
};
