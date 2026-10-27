# AGENT-README

> Orientation for AI coding agents working in this repo. Human docs: README.md.

## Type

elixir-lib

## Purpose

GitHub REST API wrapper for Elixir (`Noizu.Github`). The API surface under `lib/api/` is generated from the vendored OpenAPI description (`docs/github-api/api.github.com.json`); includes permissive schema structs, typed pagination collections, and `paginate/2` helpers.

## Stack

Elixir (~> 1.14; repo targets Elixir 1.20 / OTP 29 per `.tool-versions`). Deps: Finch + Jason; mimic for test. OTP app `:noizu_github` v0.5.0 — starts a supervised Finch pool (`Noizu.Github.Finch`) automatically.

## Dev mode

```bash
mix deps.get
```

## Ports / URLs

- none (library/CLI)

## Tests

```bash
mix test
```

## Gotchas

- Config namespace is `:noizu_github, NoizuLabs.Github.Config` (keys `api_key` / `owner` / `repo`; `GITHUB_TOKEN` env) — not `Noizu.Github`.
- `:token`, `:owner`, `:repo` can be overridden per call via the options list.
- Every request sends `Authorization: Bearer <token>` and pinned `X-GitHub-Api-Version: 2022-11-28`.
- `lib/api/` code is generated from the vendored OpenAPI spec — regenerate rather than hand-edit.
