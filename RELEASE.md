# Release Checklist

Per-release tasks for the docs. For editing conventions, see [CLAUDE.md](CLAUDE.md).

## DAPI endpoint review

1. Diff the platform proto between the previous release tag and the current release branch — that's the source of truth for what changed. Proto source: `https://github.com/dashpay/platform/tree/<branch>/packages/dapi-grpc/protos`.
2. For each affected endpoint, update both the detail page (`docs/reference/dapi-endpoints-*.md`) and the matching row on the overview page (`docs/reference/dapi-endpoints.md`), with the bold version annotation on the overview row.
3. Demote the previous release's bold annotations on the overview page to italics.
4. Re-run example requests against testnet and refresh response examples if necessary. Testnet state may have been wiped, so even unchanged endpoints may have stale data.

## Update "Previous version" links

Several pages (including the DAPI endpoints pages) link to the previous version of the docs. These links are not updated automatically. Search the site for "previous version" and update each link to point to the appropriate version.
