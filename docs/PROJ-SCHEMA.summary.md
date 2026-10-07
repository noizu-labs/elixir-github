# Project Schema (Summary)

No relational store — API-wrapper lib. Schema surface = app-env config, request
options, response contracts, vendored OpenAPI specs. Detail: PROJ-SCHEMA.md.

## App-env (`config :noizu_github, NoizuLabs.Github.Config`)

| Key | Purpose | Overridable per-call by |
|-----|---------|------------------------|
| `:api_key` | Bearer token for `Authorization` header | `token:` |
| `:owner` | Default repo owner | `owner:` |
| `:repo` | Default repo name | `repo:` |

## Request options (`api_call/5` + field helpers)

`stream` (SSE path) · `raw` (skip JSON decode → `from_binary/2`) · `token` ·
`owner`/`repo` · `response_log_callback` · any field name → body/query param.

## Response contracts

- 826 generated structs (`Noizu.Github.<Schema>`), each `from_json/2`; fallback `Raw`; empty 2xx → `nil`.
- 110 collection wrappers with pagination links (`Link` header → `%{next/prev/first/last}`).
- `Noizu.Github.Format.format/2` — hand-maintained `:basic` display projections.

## Data files

`docs/github-api/api.github.com.{yaml,json}` (latest) + `2026-03-10` pinned
snapshot — OpenAPI source of truth for `mix github.gen`.
