```{eval-rst}
.. _explanations-shielded-pool:
```

# Shielded Pool

## Overview

The shielded pool is an optional privacy layer on Dash Platform that lets users hold and move credits without revealing balances, sender, or recipient on-chain. Funds move *into* the pool through a shield transition, move *within* the pool privately, and exit through an unshield, a shielded withdrawal, or by funding a newly created identity. While funds remain inside the pool, only their owner can see them. A token can also have its own [token shielded pool](#token-shielded-pools) that holds the token instead of credits.

The pool uses the [Orchard](https://zips.z.cash/protocol/protocol.pdf) shielded protocol — the same zero-knowledge design (Halo 2 proofs, with no trusted setup) used by Zcash for its current shielded pool. Transactions inside the pool prove their own validity without disclosing the amounts or parties involved.

## When to use the shielded pool

Shielded transitions cost more than transparent ones — they carry a zero-knowledge proof and produce permanent on-chain artifacts (note commitments, nullifiers, and encrypted note ciphertexts). The fee includes a fixed proof-verification component plus a per-action component, so transitions that consume more notes cost more. Use the pool when you need confidentiality for a specific payment, transfer, or balance. Use transparent transitions for everyday activity where privacy is not a requirement.

The pool is well-suited to:

- Payments where the amount or counterparty should not be public.
- Holding balances privately before unshielding to spend transparently.
- Moving credits between identities or addresses you control without linking them.

## Core concepts

### Notes, commitments, and the note tree

Each unit of value in the pool is held as a **note** — an off-chain record describing an owner, an amount, and a unique randomness value. When a note is created, the platform records only its **commitment** (a hash of the note) into an append-only Merkle tree called the **note commitment tree**. The note itself is never published; only its commitment is, and the commitment reveals nothing about the note's contents.

The root of the note commitment tree is called an **anchor**. Anchors serve as snapshots that shielded transitions reference to prove "the note I am spending was added to the tree by some earlier transition." Spenders prove membership against an anchor without revealing *which* note they are spending.

Anchors do not remain valid indefinitely. Only a recent window of anchors is retained; older ones are pruned, and a transition referencing a pruned anchor is rejected. A wallet must therefore build its spends against a current anchor rather than reusing one it cached earlier. The retention window is given in the [Shielded Pool protocol reference](../protocol-ref/shielded-pool.md).

### Nullifiers

When a note is spent, the spender publishes a unique **nullifier** derived from the note. The platform tracks all nullifiers ever published; spending the same note twice would produce the same nullifier and be rejected as a double-spend.

Nullifiers are unlinkable to their notes' commitments. An observer can see that *some* note was spent but cannot tell which one. This is how the pool prevents double-spends while preserving privacy.

Transitions that only add notes to the pool also reveal a nullifier for each action. The platform records these as well, so resubmitting the same shield cannot create a duplicate note that could never be spent.

### Encrypted notes

When a note is created for a recipient, the platform stores an **encrypted note payload** alongside the commitment. The recipient scans new encrypted notes, attempts trial decryption with their viewing key, and learns about notes addressed to them. Other observers see only opaque ciphertext.

### Actions and the action-count limit

A shielded transition is composed of one or more **actions**. Each action structurally pairs one spend (consuming a prior note) with one output (creating a new note), bundled together so observers cannot tell which spend funded which output. The consensus rules cap a single shielded transition at **16 actions**. In practice the ~20 KiB (20,480-byte) state-transition size budget is the binding limit: because the Halo 2 proof grows with each action, a real transition fits only around 6 actions well before it reaches the 16-action cap.

## Transition types

Several state transition types interact with the shielded pool. The wire-level structure of each — including field-by-field tables and source links — is documented in the [Shielded Pool protocol reference](../protocol-ref/shielded-pool.md).

Consensus gates every transition that moves credits *out of* the pool on the pool holding a minimum number of encrypted notes. This is not a soft privacy recommendation: until the pool reaches that size, unshields, shielded withdrawals, identity creation from the pool, and identity top-ups from the pool are rejected outright. The gate exists so that exits always draw from a meaningful anonymity set, but its practical effect is that funds shielded into a young or lightly used pool cannot leave it immediately. The threshold is given in the [Shielded Pool protocol reference](../protocol-ref/shielded-pool.md).

### Shield

Moves credits *into* the pool from one or more [Platform addresses](../protocol-ref/address-system.md#platform-address) the sender controls. The total contributed across address inputs must cover the value being shielded plus the transition fee. Excess credits remain in the source addresses.

### Shield from asset lock

Moves credits *into* the pool directly from a Dash Core (L1) asset-lock transaction. This avoids first funding a Platform address and lets users enter the pool in a single Platform transition tied to an L1 lock proof. Any asset-lock value beyond the shielded amount and fee is credited to a Platform address the sender designates. If no surplus address is given, the remainder is donated to the fee pools, but only up to a small cap; a transition that would forfeit more than the cap is rejected so users cannot donate a large remainder by accident.

### Shielded transfer

Moves credits *within* the pool — between notes — without any transparent surface. To an outside observer, only the actions, anchor, proof, and binding signature are visible; the sender, recipient, and amount remain private.

### Unshield

Moves credits *out of* the pool to a [Platform address](../protocol-ref/address-system.md#platform-address) the sender designates. The unshielded amount becomes spendable through normal address-based transitions.

### Shielded withdrawal

Moves credits *out of* the pool back to Dash Core (L1) via the platform's withdrawal mechanism. Like an unshield, it reveals an amount and an L1 destination, but the funds leave Platform entirely rather than landing in a Platform address.

### Identity create from shielded pool

Creates a new identity funded directly from the pool by spending one or more notes. Like an unshield, this moves credits *out of* the pool — here into a freshly created identity rather than a Platform address. The new identity's ID is derived from the sorted set of spend nullifiers, making it unique and single-use.

The funding amount cannot be chosen freely: it must be one of a small fixed set of allowed denominations, and any other amount is rejected. Restricting the exit to standard sizes means every identity created at a given denomination looks identical on-chain, so the new identity cannot be linked back to a particular shielded balance by its amount. The permitted denominations are listed in the [Shielded Pool protocol reference](../protocol-ref/shielded-pool.md).

The notes being spent do not have to add up to the chosen denomination exactly - any excess is returned to the pool as a new note, so change stays shielded. If identity creation then fails a stateful check, the denomination still leaves the pool: it lands, less a penalty, at a fallback Platform address named in the transition.

Keys with a budget, an expiry, or a contract group binding cannot be registered when creating an identity from the pool. Add these keys afterward through an identity update.

### Shield from identity

Moves credits *into* the pool from an identity's balance, without first moving them to a Platform address.

### Identity top up from shielded pool

Moves credits *out of* the pool into the balance of an identity that already exists. Like an unshield, the amount and the destination identity are visible; only the source notes stay private.

## Token shielded pools

A token can have its own shielded pool. The pool uses the same Orchard design as the credit pool but keeps a separate note commitment tree, nullifier set, and anchors, because a note records only an amount and not which asset it holds. Tokens in one pool can therefore never be spent as credits or as another token.

A token gets a pool only if its configuration enables one when the token is created. The setting cannot be changed later. See [Tokens](./tokens.md#shielded-pool) for the configuration rules, including why pooled tokens cannot be frozen.

Most token pool operations are [token actions](./tokens.md#shielded-pool-actions) inside a batch transition. An identity signs the batch and pays its fee in credits. These actions let holders shield, transfer within the pool, and unshield. Authorized minters can mint into the pool and authorized burners can burn notes held in it. Distribution recipients can claim into the pool, and buyers can purchase tokens directly into it. Document actions that charge a token cost can also be paid from the token's pool. Three separate transitions move tokens without any identity: a shielded transfer within the token's pool, an unshield to an identity's token balance, and a direct purchase into the pool. Each pays its fee, and for a purchase the price, from the credit shielded pool. The credit pool's other exits have no token equivalent: tokens cannot be withdrawn to Dash Core or used to create or top up an identity.

A token pool's privacy depends on that token's activity alone. Its anonymity set is the notes in that pool, not every note on Platform. The credit pool's fixed minimum note count for outgoing transitions does not apply to token pools. Instead, each token's creator can set its own minimum, up to 250 notes. By default no minimum is set, so tokens can leave a new pool as soon as it holds a single note.

The [shielded endpoints](../reference/dapi-endpoints-platform-endpoints.md#shielded-transaction-endpoints) accept an optional token ID to read a token's pool instead of the credit pool.

## What the pool does not provide

- **Anonymity sets**: The privacy guarantee depends on how many other notes exist in the pool. A pool with a single user offers limited cover; privacy improves as more users participate.
- **L1 transaction privacy**: Funds entering or leaving the pool traverse transparent transitions or L1 transactions on either side. Only activity *inside* the pool is shielded.
- **Hiding the act of using the pool**: Observers can see that a transition is a shield, unshield, or transfer — they just cannot see who or how much is involved on the shielded side.
- **Hiding amounts entering or leaving the pool**: Shield and unshield transitions carry the moved amount in the clear. Only movements *within* the pool conceal value.
