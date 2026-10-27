# Changelog

Dated work log. Newest first.

## 2026-10-28

- docs: add AGENT-README.md (agent orientation)

## 2026-10-26

- docs: doc-sweep — corrected generated-surface counts (48 API modules, not 49),
  added the missing `activity` category module, documented `paginate/2` and
  `stream_pages/2` in layout/arch docs, corrected the vendored-spec provenance
  note (versionless vs `2026-03-10` snapshots have diverged), and fixed threat
  model T-001 to describe what the logged `%Finch.Response{}` actually contains
  (response body/headers; not the request's Bearer token). Direct to `develop`.
- docs: seed `.meta/pointers.yaml` with 10 doc-pointer anchors (README, core
  client, format, generator, five primary docs files) (#5).
