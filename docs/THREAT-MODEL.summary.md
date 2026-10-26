# Threat Model (Summary)

Library, not a service: outbound HTTPS to api.github.com only; no ingress, no
store. Crown jewel = GitHub token (reachable only through consumer-supplied log
callbacks; see T-005). Detail: THREAT-MODEL.md.

## Register (counts)

5 entries — 2 mitigated (T-003 spec provenance, T-004 fixed egress host) ·
1 accepted (T-005 consumer log callbacks) · 2 open.

## Open items

- T-001 Medium · Info disclosure — `Logger.warning(inspect error)` on failed calls
  dumps the whole `%Finch.Response{}` (status, response headers, **full response
  body**) into consumer logs. The Bearer token is *not* in that struct (it lives
  on the request, which is not logged); token exposure is limited to T-005's
  consumer callbacks. Log only status + body excerpt.
- T-002 Medium · DoS — `Jason.decode(keys: :atoms)` on response bodies; crafted
  content can mint unbounded atoms. Prefer `:atoms!`/key whitelisting.

## Trust boundaries

Consumer app ↔ lib (in-process) · lib ↔ GitHub REST API (HTTPS, Bearer) ·
GitHub content ↔ consumer memory/logs (decode + logging).
