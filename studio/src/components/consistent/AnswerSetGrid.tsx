import { useCasperData } from '../../hooks/useCasperData';
import { AnswerSetCard } from './AnswerSetCard';

export const AnswerSetGrid = () => {
  const { data } = useCasperData();
  if (!data) {
    return null;
  }
  return (
    <div>
      <h2 style={{ marginTop: 0 }}>Select a consistent timeline</h2>
      <div className="answer-set-grid">
        {data.answerSets.map((answerSet) => (
          <AnswerSetCard key={answerSet.id} answerSet={answerSet} />
        ))}
      </div>
    </div>
  );
};
