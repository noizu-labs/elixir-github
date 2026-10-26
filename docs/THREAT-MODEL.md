# Threat Model

<!-- 〚📁:7a02099e-3840-50f5-96cf-d873d883157d〛 elixir-github THREAT-MODEL :: Living threat model — token flow, trust boundaries, vulnerability register. -->

`elixir-github` is a **library**, not a deployed service: it runs inside a
consumer's BEAM process and makes credentialed outbound calls to
`https://api.github.com`. There is no ingress, no datastore, and no UI. The
attack surface is therefore small and centered on one crown jewel: the **GitHub
token** (`api_key` app-env or per-call `token:` option) — and on data flowing
back from GitHub into the consumer's process.

Trust boundaries: consumer app ↔ library (in-process, none) · library ↔ GitHub
REST API (HTTPS, Bearer-authenticated) · GitHub-hosted content ↔ consumer
memory/logs (decode + logging paths).

Grounding: components and flow per [PROJ-ARCH.md](PROJ-ARCH.md) /
[arch/request-flow.md](arch/request-flow.md); code map per
[PROJ-LAYOUT.md](PROJ-LAYOUT.md).

## Attack Surface

```mermaid
graph LR
    CA["Consumer app<br/>(hosts token in app env)"] -->|"api_call/5 + options"| LIB["Noizu.Github core"]
    LIB -->|"Bearer token<br/>HTTPS only"| GH["api.github.com"]
    GH -->|"JSON bodies<br/>(may embed attacker-<br/>influenced content)"| LIB
    LIB -->|"Logger.warning(inspect)"| LOGS["Consumer logs"]
    LIB -->|"log callbacks"| CB["Consumer callbacks"]
```

## Vulnerability Register

| ID | Severity | STRIDE | Component | Status |
|----|----------|--------|-----------|--------|
| T-001 | Medium | Information disclosure | `api_call/5` error paths (`noizu_github.ex`) | Open |
| T-002 | Medium | DoS | `decode_response` (`keys: :atoms`) | Open |
| T-003 | Low | Tampering | `mix github.gen` + vendored spec | Mitigated (provenance) |
| T-004 | Low | Spoofing | Token egress destination | Mitigated (by design) |
| T-005 | Low | Information disclosure | `request_log_callback` / `response_log_callback` | Accepted (consumer-owned) |

## Findings

### T-001 — Error paths log the whole response struct

Both error branches log the raw error with `Logger.warning("API ERROR: \n
#{inspect error}")` (and the `STREAM API ERROR` variant). On a non-2xx status the
`with` chain yields `{:error, %Finch.Response{}}`, so `inspect/1` writes the
response **status, response headers, and the full response body** into consumer
logs. Any repo/issue/user content or GitHub error detail returned by a failed
call lands there.

The **Bearer token is not** in that struct: `Finch.Response` (Finch `0.19`) holds
only `status`/`headers`/`body` of the *response*; the `Authorization` header lives
on the outgoing `%Finch.Request{}`, which is not part of the logged value. (The
token *can* reach logs through the consumer-supplied `request_log_callback`,
which does receive the request — see T-005.)

Mitigation: log only `status` and a body excerpt in the error paths.

### T-002 — Atom-table growth via `Jason.decode(keys: :atoms)`

All response bodies decode with `keys: :atoms` (`String.to_atom` semantics).
Most keys are spec-fixed, but endpoints returning arbitrary repo/user content
(blob bodies, variable-shape payloads) let a hostile GitHub-side or
content-influencing actor mint unbounded atoms → BEAM atom exhaustion. Mitigation:
`keys: :atoms!` + tolerant access, or a key-whitelist pass.

### T-003 — Spec poisoning feeds generated code

The vendored OpenAPI description (`docs/github-api/`) is the source the
generator turns into executable modules; a tampered spec becomes tampered code.
Mitigated by provenance: files come from `github/rest-api-description`, pinned
snapshot `2026-03-10` documented in `docs/github-api/README.md`. Re-vendor only
from upstream; diff on update.

### T-004 — Token egress destination is fixed

`@github_base "https://api.github.com"` is hardcoded (no per-call base-URL
override), so the token cannot be steered to an attacker host through library
options; Finch performs default TLS verification. Residual: DNS/pKI compromise
is out of scope for the library.

### T-005 — Log callbacks receive full request/response structs

`request_log_callback` / `response_log_callback` are consumer-supplied.
`request_log_callback` receives the outgoing `%Finch.Request{}` — including the
`Authorization: Bearer` header — and `response_log_callback` receives the
response plus the request. This is the one path by which the token can reach
logs, and it is entirely consumer-owned: the library only invokes the callbacks
the consumer installs. Accepted, documented here.

## Secret handling

The token exists only in app-env (`NoizuLabs.Github.Config`), per-call options,
and outgoing headers. The library does not persist secrets. `config/test.secret.exs`
is gitignored; no secret material is committed (verify when vendoring).

## Residual Risk

T-001 and T-002 are open code-level issues with small patches. Until T-001 is
fixed, consumers should treat error-path logs as response-content-bearing (repo
data, error bodies) — the token itself only reaches logs via consumer-supplied
callbacks (T-005). Until T-002 is fixed, avoid repeatedly calling
content-arbitrary endpoints from long-lived nodes. No other residual risk
accepted.

## Mitigation Coverage

2 mitigated · 1 accepted · 2 open (T-001, T-002 — code fixes, no tickets yet).
