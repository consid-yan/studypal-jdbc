# StudyPal Frontend

This repository has been cleaned down to the documentation archive and the frontend work that can be reused for a fresh rebuild.

## What Remains

```text
StudyPal/
+-- docs/                 Lightweight rebuild/reference documents
+-- preview/              Runnable static frontend preview pages
+-- src/main/webapp/      JSP-era frontend templates plus shared CSS/JS assets
+-- 前端设计/              Original standalone frontend design drafts
+-- LICENSE
+-- README.md
```

The Java backend, JDBC DAO/service/servlet code, SQL scripts, Maven project files, CI configuration, build output, and old report documents have been removed so the project can be rebuilt from a clean slate.

## Documents

- `docs/studypal-reference.md`: merged project reference with useful product, data-model, workflow, and rebuild notes.
- `docs/frontend-backend-integration-guide.md`: detailed frontend/backend page and Servlet integration guide.

## Run The Frontend Preview

The most reliable runnable frontend entrypoint is the static preview:

```bash
python3 -m http.server 5173
```

Then open:

```text
http://localhost:5173/preview/index.html
```

Most preview pages are plain HTML and navigate to each other within `preview/`. Several shared workspace pages still reuse CSS/JS from `src/main/webapp/assets`, so start the static server from the repository root and keep `src/main/webapp` next to `preview` unless those assets are copied into a new frontend structure later.

## Notes For Rebuild

- Treat `preview/` as the current runnable UI prototype.
- Treat `src/main/webapp/` as reusable frontend source from the old JSP application.
- Treat `docs/` as lightweight rebuild reference, not as active backend source.
- A new backend can be created independently without needing to preserve the removed Java/JDBC/Maven layout.
