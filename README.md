Stowing some of my bash rc files here so I can snag them from
any host and also for sharing.

Files work on macOS (Intel and Apple silicon) and Linux. OS differences
are branched on `uname`, and optional tools (Homebrew, gawk, nvm, ...) are
only wired up when present.

- `.bash_profile` — environment and PATH. Login shells.
- `.bashrc` — interactive setup; pulls in `.bash_profile` once for non-login shells.
- `.bash_aliases` — aliases and functions.
