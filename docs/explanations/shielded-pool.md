```{eval-rst}
.. _explanations-shielded-pool:
```

# Shielded Pool

## Overview

The shielded pool is an optional privacy layer on Dash Platform that lets users hold and move credits without revealing balances, sender, or recipient on-chain. Funds move *into* the pool through a shield transition, move *within* the pool privately, and exit through an unshield, a shielded withdrawal, or by funding a newly created identity. While funds remain inside the pool, only their owner can see them.

The pool uses the [Orchard](https://zips.z.cash/protocol/protocol.pdf) shielded protocol — the same zero-knowledge design (Halo 2 proofs, with no trusted setup) used by Zcash for its current shielded pool. Transactions inside the pool prove their own validity without disclosing the amounts or parties involved.

## When to use the shielded pool

Shielded transitions cost more than transparent ones — they carry a zero-knowledge proof and produce permanent on-chain artifacts (note commitments, nullifiers, and encrypted note ciphertexts). Use the pool when you need confidentiality for a specific payment, transfer, or balance. Use transparent transitions for everyday activity where privacy is not a requirement.

The pool is well-suited to:

- Payments where the amount or counterparty should not be public.
- Holding balances privately before unshielding to spend transparently.
- Moving credits between identities or addresses you control without linking them.

## Core concepts

### Notes, commitments, and the note tree

Each unit of value in the pool is held as a **note** — an off-chain record describing an owner, an amount, and a unique randomness value. When a note is created, the platform records only its **commitment** (a hash of the note) into an append-only Merkle tree called the **note commitment tree**. The note itself is never published; only its commitment is, and the commitment reveals nothing about the note's contents.

The root of the note commitment tree is called an **anchor**. Anchors serve as snapshots that shielded transitions reference to prove "the note I am spending was added to the tree by some earlier transition." Spenders prove membership against an anchor without revealing *which* note they are spending.

### Nullifiers

When a note is spent, the spender publishes a unique **nullifier** derived from the note. The platform tracks all nullifiers ever published; spending the same note twice would produce the same nullifier and be rejected as a double-spend.

Nullifiers are unlinkable to their notes' commitments. An observer can see that *some* note was spent but cannot tell which one. This is how the pool prevents double-spends while preserving privacy.

### Encrypted notes

When a note is created for a recipient, the platform stores an **encrypted note payload** alongside the commitment. The recipient scans new encrypted notes, attempts trial decryption with their viewing key, and learns about notes addressed to them. Other observers see only opaque ciphertext.

### Actions and the action-count limit

A shielded transition is composed of one or more **actions**. Each action structurally pairs one spend (consuming a prior note) with one output (creating a new note), bundled together so observers cannot tell which spend funded which output. The consensus rules cap a single shielded transition at **16 actions**. In practice the ~20 KiB (20,480-byte) state-transition size budget is the binding limit: because the Halo 2 proof grows with each action, a real transition fits only around 6 actions well before it reaches the 16-action cap.

## Transition types

Six state transition types interact with the shielded pool. The wire-level structure of each — including field-by-field tables and source links — is documented in the [Shielded Pool protocol reference](../protocol-ref/shielded-pool.md).

### Shield

Moves credits *into* the pool from one or more [Platform addresses](../protocol-ref/address-system.md#platform-address) the sender controls. The total contributed across address inputs must cover the value being shielded plus the transition fee. Excess credits remain in the source addresses.

### Shield from asset lock

Moves credits *into* the pool directly from a Dash Core (L1) asset-lock transaction. This avoids first funding a Platform address and lets users enter the pool in a single Platform transition tied to an L1 lock proof.

### Shielded transfer

Moves credits *within* the pool — between notes — without any transparent surface. To an outside observer, only the actions, anchor, proof, and binding signature are visible; the sender, recipient, and amount remain private.

### Unshield

Moves credits *out of* the pool to a [Platform address](../protocol-ref/address-system.md#platform-address) the sender designates. The unshielded amount becomes spendable through normal address-based transitions.

### Shielded withdrawal

Moves credits *out of* the pool back to Dash Core (L1) via the platform's withdrawal mechanism. Like an unshield, it reveals an amount and an L1 destination, but the funds leave Platform entirely rather than landing in a Platform address.

### Identity create from shielded pool

Creates a new identity funded directly from the pool by spending one or more notes. Like an unshield, this moves credits *out of* the pool — here into a freshly created identity rather than a Platform address. The new identity's ID is derived from the sorted set of spend nullifiers, making it unique and single-use.

## What the pool does not provide

- **Anonymity sets**: The privacy guarantee depends on how many other notes exist in the pool. A pool with a single user offers limited cover; privacy improves as more users participate.
- **L1 transaction privacy**: Funds entering or leaving the pool traverse transparent transitions or L1 transactions on either side. Only activity *inside* the pool is shielded.
- **Hiding the act of using the pool**: Observers can see that a transition is a shield, unshield, or transfer — they just cannot see who or how much is involved on the shielded side.
