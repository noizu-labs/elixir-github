# elixir-github

GitHub API wrapper for Elixir (`Noizu.Github`).

The full REST surface is generated from the vendored OpenAPI description in
`docs/github-api/api.github.com.json`. Generated code lives under `lib/api/`:

- `Noizu.Github.Api.<Category>` — one module per category (`Issues`, `Pulls`,
  `Repos`, …), one function per operation, dispatching through
  `Noizu.Github.api_call/5`.
- `Noizu.Github.<Schema>` — a permissive struct (`from_json/2`) per object schema.
- `Noizu.Github.Collection.<Item>` — typed list wrappers carrying pagination
  links, with generic `Noizu.Github.Collection` / `Noizu.Github.Raw` fallbacks.

## Setup

### Requirements

Elixir `1.20` / OTP `29` (see `.tool-versions`; works with recent 1.14+ releases).
Dependencies are managed with Mix: [Finch](https://github.com/sneako/finch) for
HTTP and [Jason](https://github.com/michalmuskala/jason) for JSON.

### Add the dependency

In your app's `mix.exs`:

```elixir
defp deps do
  [
    {:noizu_github, github: "noizu-labs/elixir-github", branch: "main"}
    # or pin a tag/release:
    # {:noizu_github, github: "noizu-labs/elixir-github", tag: "v0.1.0"}
  ]
end
```

```sh
mix deps.get
```

`noizu_github` is an OTP application (`Noizu.Github.Application`) that starts a
supervised Finch pool named `Noizu.Github.Finch`. It starts automatically when
your application starts its dependencies — no manual `children` entry needed.

### Provide a GitHub token

Every request sends `Authorization: Bearer <token>` and the pinned
`X-GitHub-Api-Version: 2022-11-28` header. Use a
[personal access token](https://docs.github.com/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
(or app token) with scopes appropriate to the endpoints you call.

## Configuration

```elixir
# config/runtime.exs (recommended for secrets)
config :noizu_github, NoizuLabs.Github.Config,
  api_key: System.get_env("GITHUB_TOKEN"),
  owner: "your-org",
  repo: "your-repo"
```

| Key | Required | Description |
|-----|----------|-------------|
| `:api_key` | yes | GitHub personal access token (or app token). Sent as `Authorization: Bearer <token>`. |
| `:owner` | no | Default repository owner (org or user). |
| `:repo` | no | Default repository name. |

All three can be overridden **per call** via the `options` keyword list
(`:token`, `:owner`, `:repo`), so you can target multiple repositories or
accounts from one application without reconfiguring:

```elixir
# override for a single call
{:ok, repo} = Noizu.Github.Api.Repos.get(owner: "elixir-lang", repo: "elixir")
```

> Note the config namespace is `NoizuLabs.Github.Config` under the `:noizu_github`
> app, not `Noizu.Github`.

## Usage

Each operation function takes:

1. any leading path parameters positionally (`owner`/`repo` excepted — those come
   from config/options),
2. a `body` map for write operations (`POST`/`PUT`/`PATCH`, and `DELETE` with a
   body),
3. an `options` keyword list for query params, per-call overrides, and request
   options.

### Fetch a pull request

```elixir
alias Noizu.Github.Api.Pulls

# uses owner/repo from config
{:ok, pr} = Pulls.get(42)

pr.title       # => "Add pagination helpers"
pr.state       # => "open"
pr.head.ref    # => "feature/pagination"
pr.base.ref    # => "main"
pr.html_url    # => "https://github.com/your-org/your-repo/pull/42"
pr.user        # => %Noizu.Github.SimpleUser{login: "octocat", ...}

# or target a different repo
{:ok, pr} = Pulls.get(123, owner: "elixir-lang", repo: "elixir")
```

### Create a branch

Branches are created via the Git refs API. You need the SHA of the commit to
branch from (typically the tip of `main`):

```elixir
alias Noizu.Github.Api.Git

# get the current HEAD of main
{:ok, ref} = Git.get_ref("heads/main")
sha = ref.object.sha   # => "abc123..."

# create a new branch pointing at that SHA
{:ok, _} = Git.create_ref(%{
  ref: "refs/heads/my-new-branch",
  sha: sha
})
```

### Comment on a pull request

Pull request comments go through the Issues API (GitHub treats PRs as issues
for comments). Use `Issues.create_comment/3` with the PR number:

```elixir
alias Noizu.Github.Api.Issues

{:ok, comment} = Issues.create_comment(42, %{
  body: "Looks good! :shipit:"
})

comment.id        # => 123456789
comment.html_url  # => "https://github.com/your-org/your-repo/issues/42#issuecomment-..."
```

For inline review comments on specific lines of a diff, use the Pulls API instead:

```elixir
alias Noizu.Github.Api.Pulls

# comment on a specific line in the diff
{:ok, _} = Pulls.create_review_comment(42, %{
  body: "Consider using `Enum.map` here.",
  commit_id: "abc123...",
  path: "lib/my_module.ex",
  line: 15
})

# or submit a full review (approve / request changes / comment)
{:ok, _} = Pulls.create_review(42, %{
  event: "APPROVE",
  body: "LGTM!"
})
```

### More examples

```elixir
alias Noizu.Github.Api.{Issues, Repos, Search, Users}

# issues
{:ok, issues} = Issues.list_for_repo(state: "open", per_page: 50)
{:ok, issue}  = Issues.create(%{title: "Bug", body: "..."})
{:ok, _}      = Issues.update(42, %{state: "closed"})

# repos
{:ok, repo}  = Repos.get()
{:ok, _}     = Repos.create_release(%{tag_name: "v1.0.0", name: "v1.0.0", body: "..."})

# search
{:ok, results} = Search.repos(q: "language:elixir stars:>1000", sort: "stars")

# users
{:ok, user} = Users.get_by_username("octocat")
```

### Pagination

Two built-in helpers walk paginated endpoints automatically. Both accept any
generated list function (as a capture) and your initial options:

**`paginate/2`** — eagerly fetches all pages and returns `{:ok, all_items}`:

```elixir
{:ok, all_issues} = Noizu.Github.paginate(
  &Noizu.Github.Api.Issues.list_for_repo/1,
  state: "open", per_page: 100
)
# all_issues => [%Noizu.Github.Issue{}, %Noizu.Github.Issue{}, ...]
```

**`stream_pages/2`** — returns a lazy `Stream` yielding one `{:ok, page_result}`
per page, so you can process or short-circuit without fetching everything:

```elixir
Noizu.Github.stream_pages(
  &Noizu.Github.Api.Issues.list_for_repo/1,
  state: "open", per_page: 100
)
|> Enum.flat_map(fn
  {:ok, %{items: items}} -> items
  {:error, _} -> []
end)
```

Both helpers increment the `:page` option and follow `links[:next]` until the
API signals no more pages. Errors propagate: `paginate/2` returns the first
`{:error, _}` immediately; `stream_pages/2` yields it as the final element.

Each page result also carries `links` (`%{first:, prev:, next:, last:}` URLs
parsed from the `Link` header via `Noizu.Github.extract_links/1`) if you need
manual control.

### Curated views

Generated structs are full and spec-faithful. For compact display, the
hand-maintained `Noizu.Github.Format` module (`lib/format.ex`, not generated)
exposes curated `:basic` projections:

```elixir
{:ok, issues} = Noizu.Github.Api.Issues.list_for_repo(state: "open")
Noizu.Github.Format.format(issues, :basic)
# => [%{id: 1, title: "...", state: "open", user: %{login: ...}, labels: [...]}, ...]
```

Unknown shapes pass through unchanged, so `format/2` is always safe to call.

## Response shapes & errors

- `{:ok, struct}` — a single object, decoded into `Noizu.Github.<Schema>` (or
  `Noizu.Github.Raw` for inline/union/empty bodies).
- `{:ok, collection}` — a list result: `Noizu.Github.Collection.<Item>` when the
  item schema is known, else the generic `Noizu.Github.Collection`. Both expose
  `items`, `total`, `complete`, and `links`.
- `{:error, term}` — on failure. For an HTTP non-2xx the term is the full
  `%Finch.Response{}` (inspect its `:status` and `:body`); transport errors
  propagate as-is.

Generated structs are permissive: extra and missing keys are tolerated, so the
client is robust to minor API drift.

## Timeouts

Requests use generous timeouts (`pool_timeout` and `receive_timeout` of
`600_000` ms / 10 min) to accommodate long-running endpoints and rate limiting.
Adjust at the transport level if you need stricter limits.

## Testing

The decode path is exercised with [Mimic](https://github.com/hamiltop/mimic),
stubbing `Finch.request/3` with canned responses — no network access required
(`test/api/issues_test.exs`). In your own app, the same seam lets you stub Finch
to assert on the URLs and bodies your code produces.

Run the suite:

```sh
mix test
```

`config/test.secret.exs` (gitignored) supplies test defaults; copy the pattern
and set `GITHUB_TOKEN` for any integration-style tests you add.

## Regenerating

After updating `docs/github-api/api.github.com.json`, regenerate the client:

```sh
mix github.gen
mix compile
mix test
```

`mix github.gen` wipes and rewrites `lib/api/`. The runtime core in
`lib/noizu_github.ex` (`api_call/5`, `headers/1`, `extract_links/1`,
`get_field/3`, `put_field/4`) is hand-maintained and not generated.

## Further reading

- [docs/PROJ-ARCH.md](docs/PROJ-ARCH.md) — architecture overview.
- [docs/PROJ-LAYOUT.md](docs/PROJ-LAYOUT.md) — directory map.
- [docs/github-api/README.md](docs/github-api/README.md) — provenance of the
  vendored OpenAPI spec.
