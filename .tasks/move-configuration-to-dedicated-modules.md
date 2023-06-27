Move configuration to dedicated modules
=======================================

Prepare a `modules/` directory for the following programs:

| program         | module
|-----------------|---------
| qutebrowser     | browser
| kitty           | terminal
| fish            | shell
| neovim          | editor
| git             | vcs
| gpg, pass, etc. | crypto

Organize the configuration in such manner that the program configuration is
independent of it's dependencies.
