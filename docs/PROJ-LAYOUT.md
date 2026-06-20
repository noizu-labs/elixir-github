# Project Layout

`elixir-github` — GitHub API wrapper for Elixir (`:noizu_github`). The full REST
surface is generated from a vendored OpenAPI description; generated code lives
under `lib/api/`.

```
elixir-github/
├── lib/                        # Source code → [layout/lib.md](layout/lib.md)
│   ├── noizu_github.ex         #   Core client: api_call/5, headers, pagination
│   ├── application.ex          #   OTP app; starts the Finch HTTP pool
│   ├── format.ex               #   Curated :basic display projections (hand-maintained)
│   ├── api/                    #   Generated API + structs → [layout/api.md](layout/api.md)
│   └── mix/                    #   `mix github.gen` code generator
├── config/                     # Compile/runtime configuration
│   ├── config.exs              #   Base config; imports env-specific file
│   ├── runtime.exs             #   Runtime config (currently empty)
│   ├── dev.exs                 #   Dev environment overrides
│   ├── prod.exs                #   Production environment overrides
│   ├── test.exs                #   Test environment overrides
│   └── test.secret.exs         #   Local test secrets (gitignored)
├── docs/                       # Documentation
│   ├── PROJ-LAYOUT.md          #   This file
│   └── github-api/             #   Vendored OpenAPI specs (see below)
├── test/                       # Test suites
│   ├── test_helper.exs
│   ├── api/issues_test.exs     #   Client behaviour tests (uses mimic)
│   └── gen/generator_test.exs  #   Generator regression tests
├── priv/                       # App priv assets
│   ├── static/                 #   favicon.ico, robots.txt, images/logo.svg
│   ├── gettext/                #   Default gettext error templates
│   └── repo/                   #   seeds.exs + (empty) migrations scaffold
├── .tool-versions             # Required runtimes — asdf/mise
├── .gitignore                  # Ignores deps/_build/.tool-versions/.envrc/secrets
├── mix.exs                     # Project + dependency definition
├── mix.lock                    # Locked dependency versions
├── LICENSE                     # MIT
└── README.md                   # Start here — usage & configuration
```

## lib/ breakdown

See [layout/lib.md](layout/lib.md) for the per-file detail of the hand-maintained
top-level modules (`noizu_github.ex`, `application.ex`, `format.ex`) and the
`mix github.gen` task.

## lib/api/ breakdown

49 generated category modules, 826 schema structs, and 110 collection wrappers —
too large for this file. See [layout/api.md](layout/api.md) for the category list
and the struct/collection grouping.

## docs/github-api/

Vendored copies of GitHub's official REST API OpenAPI descriptions, sourced from
<https://github.com/github/rest-api-description>. These are the source of truth
the generator reads. See `docs/github-api/README.md` for details.

| File | Description |
| --- | --- |
| `api.github.com.{yaml,json}` | Canonical "latest" (versionless) descriptions. |
| `api.github.com.2026-03-10.{yaml,json}` | Latest dated snapshot (pinned). |

## Key files requiring setup

| File | Action |
|------|--------|
| `config/test.secret.exs` | Create locally; gitignored. Holds `api_key` for integration tests. |
| `.envrc` | Create locally; gitignored. Used with direnv for shell env (`GITHUB_TOKEN`, etc.). |
| `.tool-versions` | Present but gitignored; ensures Elixir 1.20 / OTP 29 via asdf/mise. |

## Required runtimes

From `.tool-versions`: Elixir `1.20.1-otp-29`, Erlang/OTP `29.0.2`.

## Dependencies (mix.exs)

| Dep | Purpose |
|-----|---------|
| `finch` | HTTP client; the `Noizu.Github.Finch` pool. |
| `jason` | JSON encode/decode. |
| `mimic` | Test-only stubbing of Finch. |
| `ex_doc` | Dev-only documentation generation. |
