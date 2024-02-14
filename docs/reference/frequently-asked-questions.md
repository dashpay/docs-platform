```{eval-rst}
.. _reference-faq:
```

# Frequently Asked Questions

## What is Evolution?

"Evolution" is a codename used to reference various products. It includes "Dash Platform," a FireBase-like platform for developing backends for websites and applications, hosted on the masternode network.

Also, the term " Evolution" refers to several other products that we are going to develop on top of the platform. An example of such an app is DashPay - an easy to use payment solution with usernames and contact lists.

## How does a DAPI client discover the IP address of masternodes hosting DAPI endpoints?

The DNS seed will provide a deterministic masternode list (DML) to the client. More on the deterministic MN list can be found here:

- DML spec: https://github.com/dashpay/dips/blob/master/dip-0003.md
- DML verification: https://github.com/dashpay/dips/blob/master/dip-0004.md

## Why can't I connect to DAPI from a page served over HTTPS?

Modern browsers block connections to insecure content when the main page is loaded securely. At the moment, there are technical obstacles to serving DAPI content over HTTPS. Until then, the only way to test DAPI from a web page is to serve the web page insecurely. Dash Core team is evaluating different ways to work around this browser restriction and have a trustworthy connection to DAPI.

## Will it be possible to use apps with only an identity, or will a DPNS name have to be registered first?

Apps can interact with an identity whether or not it has a DPNS name registered. Someone may create an app that requires one, but it's not a platform restriction.

## Should it be possible to create multiple identities using a single private key?

It may not be a very good practice, but this is not restricted.

## Will DAPI RPCs always be free? How will DoS attacks be mitigated?

Right now there's only IP based rate limits. Generally Core team wants platform data to be available for everyone, so there are no plans today to have paid queries.

## When I try to load the Dash javascript library, why is there is a syntax error "Invalid regular expression"?

This can be caused by loading the script with the wrong character encoding. The `dash` npm package uses UTF-8 encoding. Try this:
`<script src="https://unpkg.com/dash" encoding="UTF-8"></script>`
