# Project Schema

`elixir-github` is an API-wrapper library (`:noizu_github`) with **no relational
persistence** — no Ecto schemas, migrations, or KV store. The "schema" surface is:

1. App-env configuration consumed by the client
2. Request option contracts (`api_call/5`, generated functions)
3. Response contracts (generated structs, pagination links, `:basic` projections)
4. The vendored OpenAPI descriptions that drive generation

Code organization → [PROJ-LAYOUT.md](PROJ-LAYOUT.md); request/generation flow →
[PROJ-ARCH.md](PROJ-ARCH.md).

## App-env config (`config :noizu_github, NoizuLabs.Github.Config`)

Read at call time (not compile time) by `Noizu.Github` (`lib/noizu_github.ex`):

| Key | Type | Read by | Purpose |
|-----|------|---------|---------|
| `:api_key` | string | `headers/1` | `Authorization: Bearer <api_key>`; per-call `token:` option overrides |
| `:owner` | string | `repo_owner/1` | Default repo owner; per-call `owner:` option overrides |
| `:repo` | string | `repo_name/1` | Default repo name; per-call `repo:` option overrides |

Precedence everywhere: call option → app env → `nil` (generated functions then
omit the path segment or error).

Config files: `config/config.exs` (logger + env import), `dev.exs`, `prod.exs`,
`runtime.exs` (empty), `test.exs` (imports `test.secret.exs` — gitignored, holds
the test `api_key`).

## Request option contract (`options`)

Common option keys handled by `Noizu.Github.api_call/5` and the field helpers
(`put_field/4`, `get_field/3`):

| Option | Type | Effect |
|--------|------|--------|
| `:stream` | boolean | Route through the SSE-style stream reducer instead of Finch fetch |
| `:raw` | boolean | Skip JSON decode; return body via the model's `from_binary/2` |
| `:token` | string | Override configured `api_key` for this call |
| `:owner` / `:repo` | string | Override configured default owner/repo |
| `:response_log_callback` | fun | Finch request/response logging hook |
| any field name | term | Copied into the request body (`put_field`) or query string (`get_field`) |

## Response contracts

- **Structs** — one per OpenAPI object schema (`Noizu.Github.<Schema>`, 826
  structs), each with `from_json/2` (atom-keyed decode). Fallback for unmapped
  objects: `Noizu.Github.Raw`. Empty success bodies (`204`/`202`) decode to `nil`.
- **Collections** — `Noizu.Github.Collection.<Item>` (110 wrappers) carry
  `items` plus pagination links.
- **Pagination links** — `Noizu.Github.extract_links/1` parses the `Link` header
  into `%{next: url, prev: url, first: url, last: url}` (only rels present).
- **`:basic` projections** — `Noizu.Github.Format.format/2` layers curated
  display maps (Issue, SimpleUser, Label, …) over the permissive generated
  structs. Hand-maintained; not generator output.

## Data files — vendored OpenAPI descriptions

Source of truth for the generated surface; read by `mix github.gen`.
See `docs/github-api/README.md`.

| Path | Purpose |
|------|---------|
| `docs/github-api/api.github.com.{yaml,json}` | Canonical "latest" (versionless) descriptions |
| `docs/github-api/api.github.com.2026-03-10.{yaml,json}` | Pinned dated snapshot |

Counts currently asserted by the tree: 49 category modules, 826 structs,
110 collection wrappers (`test/gen/generator_test.exs` guards coverage).
