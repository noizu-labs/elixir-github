# Project Layout (Summary)

Tree mirror of `PROJ-LAYOUT.md`, kept in sync on structural changes.

```
elixir-github/
├── lib/                        # Source code → layout/lib.md
│   ├── noizu_github.ex         #   Core client (api_call/5, headers, pagination)
│   ├── application.ex          #   OTP app; starts Finch HTTP pool
│   ├── format.ex               #   Curated :basic display projections
│   ├── api/                    #   Generated API + structs → layout/api.md
│   │   ├── <category>/         #     49 API modules
│   │   └── structs/            #     826 structs + collection/ (110)
│   └── mix/tasks/github.gen.ex #   `mix github.gen` generator
├── config/                     # config/dev/prod/test/runtime.exs + test.secret.exs
├── docs/                       # PROJ-LAYOUT.md, layout/, github-api/ (OpenAPI specs)
├── test/                       # api/issues_test.exs, gen/generator_test.exs
├── priv/                       # static/, gettext/, repo/
├── .tool-versions             # Elixir 1.20 / OTP 29
├── .gitignore
├── mix.exs                     # :noizu_github project + deps
├── mix.lock
├── LICENSE                     # MIT
└── README.md
```
