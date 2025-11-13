# CASPER Studio

CASPER Studio is a Vite + React interface that parses CASPER's JSON output and visualises the inferred clinical events on top of a vis-timeline chart.

## Architecture overview

```
studio/
├── src/
│   ├── components/
│   │   ├── common/ModeSelector.tsx
│   │   ├── consistent/AnswerSetGrid.tsx
│   │   ├── layout/{Header,ConfigPanel}.tsx
│   │   ├── stats/StatsPanel.tsx
│   │   └── timeline/TimelineView.tsx
│   ├── config/timeConfig.ts
│   ├── context/CasperProvider.tsx
│   ├── hooks/useCasperData.ts
│   ├── services/{casperParser,casperService}.ts
│   ├── types/casper.ts
│   ├── utils/{atomParser,time}.ts
│   └── mock/*.json
├── server/index.js
├── package.json
├── tsconfig*.json
└── vite.config.ts
```

- **State management** lives in `CasperProvider`, which loads JSON results for each mode, stores the active answer set, and exposes configuration handlers.
- **Data layer** is composed of `casperService` (fetch/mock logic) and `casperParser` (normalization of `event(...)` atoms into strong TypeScript types).
- **TimelineView** wraps `vis-timeline`, handles gradient colouring based on the confidence level, and renders point events when `(start === end)`.
- **Consistent mode UX** relies on `AnswerSetGrid` cards that summarise each witness and let the user pick which answer set populates the main timeline.
- **Statistics & configuration panels** expose solver metadata, time conversions, and mock controls to launch CASPER from the UI.
- **Node backend** (`server/index.js`) exposes `/api/apps`, `/api/results`, `/api/results/files`, and `/api/run`. It shells out to `execution/run_casper.sh`, streams CASPER's logs, stores solver output under `results/<app>/<mode>/`, and serves the latest JSON file to the React client.

## Development scripts

```bash
cd studio
npm install        # requires network access to npm registry
npm run server     # starts the backend on http://localhost:4000
npm run dev        # launches Vite dev server with proxying to /api
```

### Backend endpoints

| Method | Endpoint             | Description |
| ------ | -------------------- | ----------- |
| GET    | `/api/apps`          | Lists available CASPER apps (directories inside `/app`). |
| GET    | `/api/results`       | Returns the most recent JSON output for the requested `app` + `mode`. Pass `file=results_*.json` to fetch a specific run. |
| GET    | `/api/results/files` | Lists the JSON files that already exist under `results/<app>/<mode>/` so you can pick historical runs. |
| POST   | `/api/run`           | Launches `execution/run_casper.sh` with the provided payload (`appName`, `mode`, `threads`, `unit`, `windowStart/End`, `parameters`, etc.). Responds with CASPER's stdout/stderr plus the detected output path. |

All endpoints assume the server process runs from `studio/` so it can resolve the monorepo root via `../`. The `/api/run` controller automatically switches `--repair` to `yes` for consistent, preferred, and cautious runs unless you override the flag manually.

When npm registry access is unavailable, you can still inspect the TypeScript source files and wire the dependencies manually in your target environment.
