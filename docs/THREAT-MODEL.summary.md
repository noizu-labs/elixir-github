# Threat Model (Summary)

Library, not a service: outbound HTTPS to api.github.com only; no ingress, no
store. Crown jewel = GitHub token. Detail: THREAT-MODEL.md.

## Register (counts)

5 entries — 2 mitigated (T-003 spec provenance, T-004 fixed egress host) ·
1 accepted (T-005 consumer log callbacks) · 2 open.

## Open items

- T-001 High · Info disclosure — `Logger.warning(inspect error)` on failed calls
  can dump `%Finch.Response{}` incl. the `Authorization: Bearer` header into
  consumer logs. Redact headers in error paths.
- T-002 Medium · DoS — `Jason.decode(keys: :atoms)` on response bodies; crafted
  content can mint unbounded atoms. Prefer `:atoms!`/key whitelisting.

## Trust boundaries

Consumer app ↔ lib (in-process) · lib ↔ GitHub REST API (HTTPS, Bearer) ·
GitHub content ↔ consumer memory/logs (decode + logging).
