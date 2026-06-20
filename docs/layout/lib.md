# lib/ — Source Code

Hand-maintained top-level modules plus the generated `api/` tree.

```
lib/
├── noizu_github.ex      # Core client — see below
├── application.ex       # OTP Application; starts {Finch, name: Noizu.Github.Finch}
├── format.ex            # Hand-maintained curated :basic display projections
├── api/                 # Generated API + structs → [api.md](api.md)
└── mix/
    └── tasks/
        └── github.gen.ex  # `mix github.gen` — generates lib/api from the OpenAPI spec
```

## noizu_github.ex (`Noizu.Github`)

The core client every generated module imports.

- `api_call/5` — the central HTTP entry point. Dispatches to fetch or stream mode,
  decodes the response, and applies the target model's `from_json/2` (or
  `from_binary/2` for `raw`).
- `headers/1` — builds the auth + `X-GitHub-Api-Version: 2022-11-28` headers.
- `github_base/0` — `"https://api.github.com"`.
- `repo_name/1`, `repo_owner/1` — resolve owner/repo from options or app config.
- `extract_links/1` — parses `Link` headers into `%{next: _, last: _, ...}` for
  pagination.
- `put_field/4`, `get_field/3` — query/body field helpers used by generated code.
- `generic_stream_provider/1` — SSE-style stream reducer (legacy chat-style path).

## application.ex (`Noizu.Github.Application`)

OTP app entry (`mod` in `mix.exs`). Supervision tree starts a single
`{Finch, name: Noizu.Github.Finch}` child — the HTTP pool all requests use.

## format.ex (`Noizu.Github.Format`)

Hand-maintained, curated views over the generated structs. The generated structs
are spec-faithful and permissive; this module layers the `:basic` projections the
original hand-written client exposed, without touching (or being wiped by) the
generator output.

## mix/tasks/github.gen.ex

`mix github.gen` reads the vendored OpenAPI spec in `docs/github-api/` and emits
the category modules and structs under `lib/api/`. Generated files carry a
"do not edit by hand" banner. Coverage is asserted by
`test/gen/generator_test.exs`.
