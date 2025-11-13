import { useContext } from 'react';
import { CasperContext } from '../context/CasperProvider';

export const useCasperData = () => {
  const ctx = useContext(CasperContext);
  if (!ctx) {
    throw new Error('useCasperData must be used within CasperProvider');
  }
  return ctx;
};
