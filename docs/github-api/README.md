# GitHub REST API OpenAPI Specs

Vendored copies of GitHub's official REST API OpenAPI descriptions, sourced from
the canonical repository: <https://github.com/github/rest-api-description>

These describe `https://api.github.com`, which is the `@github_base` target used
by this library (`lib/noizu_github.ex`), along with the
`X-GitHub-Api-Version: 2022-11-28` header (the `apiVersion` these specs target).

## Files

| File | Description |
| --- | --- |
| `api.github.com.yaml` / `api.github.com.json` | Canonical "latest" (versionless) descriptions. |
| `api.github.com.2026-03-10.yaml` / `api.github.com.2026-03-10.json` | Latest dated snapshot (2026-03-10). |

All four are OpenAPI `3.0.3`, info version `1.1.4`, 787 paths. The versionless and
`2026-03-10` files are currently identical; both are kept so a pinned snapshot is
available even after the versionless files advance.

## Updating

Re-download the latest versions from the `main` branch:

```bash
BASE="https://raw.githubusercontent.com/github/rest-api-description/main/descriptions/api.github.com"
curl -fsSL "$BASE/api.github.com.yaml"      -o docs/github-api/api.github.com.yaml
curl -fsSL "$BASE/api.github.com.json"      -o docs/github-api/api.github.com.json
```

To pin a specific dated snapshot, use the `api.github.com.<YYYY-MM-DD>.{yaml,json}`
filenames from the `descriptions/api.github.com/` directory of that repo.

## Source license

The upstream specs are MIT licensed (see `license` field inside each file).
