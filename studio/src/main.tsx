import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './styles.css';
import { CasperProvider } from './context/CasperProvider';

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <CasperProvider>
      <App />
    </CasperProvider>
  </React.StrictMode>
);
