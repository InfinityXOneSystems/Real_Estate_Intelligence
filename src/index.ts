// Minimal project entrypoint — re-exports the API server so
// `node dist/index.js` works in CI smoke tests and local builds.
import './api-server';

// Exporting nothing; importing `api-server` starts the app when run.
export {};
