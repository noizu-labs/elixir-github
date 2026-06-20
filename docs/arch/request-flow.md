# Request & Decode Flow

How a generated endpoint call reaches `api.github.com` and comes back typed.

## The single entry point

Every `Noizu.Github.Api.<Category>` function follows the same shape:

1. Resolve `owner`/`repo` from options or app config (`repo_owner/1`,
   `repo_name/1`) and interpolate path params.
2. Build the query string from `get_field/3` for any supported query params.
3. Build the body (`%{}` for read/delete, the caller's `body` map for writes).
4. Call `api_call(method, url, body, <model>, options)`, where `<model>` is a
   module atom chosen at generation time.

All transport logic is centralized in `Noizu.Github.api_call/5`.

## `api_call/5` decode path (non-stream)

```
api_call(type, url, body, model, options)
  │
  ├─ encode body (Jason); nil body → {:ok, nil}
  ├─ api_call_fetch/4 → Finch.request(Noizu.Github.Finch, [long timeouts])
  │     ├─ tap request_log_callback(finch)   if provided
  │     └─ tap response_log_callback(finch, request, start_ms) if provided
  ├─ status in 200..299? else {:error, %Finch.Response{}}
  ├─ decode_response/2:
  │     "" / nil   → {:ok, nil}      (204/202 empty bodies)
  │     raw: true  → body verbatim   (from_binary/2 path)
  │     else       → Jason.decode(body, keys: :atoms)
  └─ apply(model, :from_json, [json, headers])
        └─ model resolves the typed struct / collection / Raw
```

On any `else` branch it logs via `Logger.warning` and returns the error tuple
unchanged — failures propagate as `{:error, term}`.

## Headers

`headers/1` sets: `Accept: application/vnd.github+json`,
`Content-Type: application/json`, `Authorization: Bearer <token>` (from
`options[:token]` or app config), and the pinned
`X-GitHub-Api-Version: 2022-11-28` matching the vendored spec.

## Streaming

When `options[:stream]` is truthy, `api_call/5` routes to `api_call_stream/4`,
which uses `Finch.stream/4` with a `%{status, raw, message}` accumulator and the
caller's callback. (The `generic_stream_provider/1` reducer handles an
OpenAI-style `data:` SSE delta format — a legacy path retained from the
client's origins, not used by the generated GitHub surface.)

## Pagination

Pagination links travel out-of-band via the HTTP `Link` header, not the body:

- `extract_links/1` parses `Link` into `%{first:, prev:, next:, last:}` of URLs.
- Every `from_json/2` model receives `headers` and stashes the parsed map in the
  result's `:links` field (structs via `Raw`, collections in `:links`).
- Callers drive the next page themselves using `result.links[:next]` — there is
  no auto-pagination loop in the core. (The recent `[wip] continuation and
  pagination support` commit added the link plumbing; client-side iteration is
  left to the consumer.)

Search/list endpoints additionally return `{total_count, items,
incomplete_results}` envelopes; collection `from_json/2` normalizes these into
`%{items, total, complete}` where `complete` reflects `incomplete_results`.

## Logging hooks

Both fetch and stream paths accept optional callbacks in `options`:
`request_log_callback` (`fn finch` / `{m, f}`) and `response_log_callback`
(`fn finch, request, start_ms` / `{m, f}`). They are no-ops when absent.

## Test seam

`Finch.request/3` and `Finch.stream/4` are stubbed with Mimic in
`test/api/issues_test.exs`, letting the decode + pagination path be exercised
against canned responses without network access.
