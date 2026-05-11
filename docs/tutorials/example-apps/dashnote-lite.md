---
html_theme.sidebar_secondary.remove: true
---

```{raw} html
<style>
  /* Widen content area on this embed page since both sidebars are hidden.
     The theme's .bd-main .bd-content .bd-article-container caps at 60em (~960px). */
  .bd-main .bd-content .bd-article-container { max-width: 1100px; }
</style>
```

# Dashnote Lite

The app embedded below is a live, read-only version of Dashnote running against testnet — try
it out directly in this page.

It's a stripped-down companion to the full [Dashnote](dashnote.md) notes example app: browse the
recent notes for any identity ID, or fetch a single note by document ID, against the bundled
default contract. No wallet, identity, or signing required. Writes (create, update, delete) aren't
wired up here; for the walkthrough of those SDK calls, see the [Dashnote tutorial](dashnote.md).

```{raw} html
<iframe src="../../../_static/dashnote-lite.html" width="100%" height="600"></iframe>
```
