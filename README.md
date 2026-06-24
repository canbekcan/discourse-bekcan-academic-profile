# Discourse BEKCAN Academic Profile

A Discourse plugin designed to manage academic profiles, enforce specific user fields, and automatically map academic titles to specific Discourse groups via an administrative interface.

## Features
* Modern Admin UI built with Ember Glimmer (`.gjs`).
* Automated Background Group Synchronization (via Zeitwerk Service Objects).
* Multi-select group assignment matrix.
* Thread-safe user field generation (`DistributedMutex`).

## Installation

Follow the [Install a Plugin](https://meta.discourse.org/t/install-a-plugin/19157) guide from the official Discourse Meta, adding this repository URL to your `app.yml`:

```yml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone [https://github.com/canbekcan/discourse-bekcan-academic-profile.git](https://github.com/canbekcan/discourse-bekcan-academic-profile.git)