# Project Architecture (Summary)

Quick-reference mirror of `PROJ-ARCH.md`, kept in sync on significant changes.

## Overview

`elixir-github` (`:noizu_github`) is a spec-driven Elixir client for the GitHub
REST API. A generator (`mix github.gen`) emits the full client surface (category
modules, permissive schema structs, typed collection wrappers) from a vendored
OpenAPI spec; a small hand-written core owns HTTP transport and curated display
views. Generated code is disposable; hand-written code survives regeneration.

## Core Components

- `Noizu.Github` — core client: single HTTP entry `api_call/5`, auth/version
  headers, `Link`-header pagination parsing.
- `Noizu.Github.Application` — OTP app supervising the Finch HTTP pool.
- `Mix.Tasks.Github.Gen` — generator: OpenAPI spec → all of `lib/api/`.
- `Noizu.Github.Api.<Category>` (49) — generated; one function per operation.
- `Noizu.Github.<Schema>` (826) — generated permissive `from_json/2` structs.
- `Noizu.Github.Collection.<Item>` (110) — generated typed list results w/ links.
- `Noizu.Github.Raw` / `Noizu.Github.Collection` — generated fallback models.
- `Noizu.Github.Format` — hand-maintained curated `:basic` display projections.

## Flow

Caller → generated category function → `api_call/5` → Finch pool →
`api.github.com` → decode (`apply(model, :from_json, [json, headers])`) → typed
result with `:links`. One dispatch point; model atom baked into each call.

## Key Decisions

- Spec-driven generation (787 paths); only transport core + curated views
  hand-written.
- Single `api_call/5` dispatch point for all transport concerns.
- Permissive generated structs + hand-written curated projection layer.
- Typed-but-fallback collections carrying pagination links.
- Generated code isolated under `lib/api/`; hand-written code regenerates clean.

## Stack

Elixir 1.20 / OTP 29 · Finch (`~> 0.19`) · Jason (`~> 1.2`) · vendored GitHub
OpenAPI · Mimic (test) · ex_doc (dev).

## Detail docs

- `arch/request-flow.md` — decode path, status/stream/pagination, logging hooks.
- `arch/generation.md` — spec-to-code mapping, decode conventions, fallbacks.
