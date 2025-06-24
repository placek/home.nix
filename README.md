# placek's Home Manager configuration repository

This repository contains the configuration files and modules for managing a
Nix-based system using Home Manager. The configuration is organized into several
key modules and concepts to provide a structured and maintainable setup.

## TOC

- [Overview](#overview)
- [Modules](#modules)
  - [Shell](#shell)
  - [Editor](#editor)
  - [Browser](#browser)
  - [Mail](#mail)
  - [Security](#security)
  - [Terminal](#terminal)
  - [GUI](#gui)
  - [Utilities](#utilities)
  - [Machines](#machines)
- [Concepts](#concepts)
  - [Session Variables](#session-variables)
  - [File Management](#file-management)
  - [Network Configuration](#network-configuration)
  - [Service Management](#service-management)
- [Structure](#structure)
  - [Directory Layout](#directory-layout)
  - [Configuration Files](#configuration-files)

## Overview

The repository is designed to manage personal configurations for different tools
and services using Nix and Home Manager. It includes settings for various
applications, custom scripts, and system services tailored to specific machines.

## Modules

### Shell

- **Configuration**: `modules/shell`
- **Description**: Defines shell settings, including session variables and
  bookmarks.

### Editor

- **Configuration**: `modules/editor`
- **Description**: Configures editor settings and session variables.

### Browser

- **Configuration**: `modules/browser`
- **Description**: Manages browser settings, search engines, and key bindings.

### Mail

- **Configuration**: `modules/mail`
- **Description**: Sets up mail accounts and related services.

### Security

- **Configuration**: `modules/security`
- **Description**: Configures security settings, including GPG and SSH.

### Terminal

- **Configuration**: `modules/terminal`
- **Description**: Defines terminal emulator settings.

### GUI

- **Configuration**: `modules/gui`
- **Description**: Manages graphical user interface settings. The bar is powered by [Eww](https://github.com/elkowar/eww).

### Utilities

- **Configuration**: `modules/utils`
- **Description**: Configures various utility programs and scripts.

### Machines

- **Configuration**: `machines/`
- **Description**: Machine-specific configurations, such as network settings,
  services, and hardware options.

## Structure

### Directory Layout

The repository is structured into different directories, each containing
configurations for specific areas:

- `modules/`: Contains module configurations.
- `machines/`: Contains machine-specific configurations.
- `settings/`: Contains general settings and options.

### Configuration Files

Each configuration file follows a specific naming convention and is responsible
for a particular aspect of the system configuration. Examples include:

- `modules/shell`: Shell configuration.
- `modules/editor`: Editor configuration.
- `machines/alpha/configuration.nix`: Configuration for the Alpha machine.

## Usage

This configuration can be managed using a set of helper commands defined in the
Makefile. Below is a description of each command and its usage:

### Applying Configuration

To apply the Home Manager configuration and create a backup:

```sh
make apply
```

This command uses the `home-manager` flake to apply the configuration with the
`--impure` option, creating a backup of the existing setup.

### Linking Configuration

To link the current machine's configuration to `/etc/nixos/configuration.nix`:

```sh
make /etc/nixos/configuration.nix
```

This command uses `cp` with the `--backup`, `--interactive`, and `--link`
options to create a hard link from `machines/$$(hostname)/configuration.nix` to
`/etc/nixos/configuration.nix`.

### Switching Configuration

To switch to the new NixOS configuration:

```sh
make switch
```

This command links the configuration (as described above) and then runs
`nixos-rebuild switch` to apply it.

### Upgrading System

To upgrade the system configuration:

```sh
make upgrade
```

This command links the configuration and then runs `nixos-rebuild switch
--upgrade` to apply the configuration and upgrade the system.

### Expiring Old Generations

To expire old generations:

```sh
make expire
```

This command runs `home-manager expire-generations` with the expiration period
set to 30 days (or the period specified in the `expiration` variable).

### Listing Generations

To list current generations:

```sh
make gens
```

This command lists all the generations managed by `home-manager`.

### Garbage Collection

To run garbage collection:

```sh
make gc
```

This command deletes store paths older than the specified expiration period
(default is 30 days), optimizes the Nix store, and frees up space.

### Additional Notes

- **Home Manager Flake**: The Home Manager flake is defined as
  `home-manager/release-23.11` in the `hm-flake` variable.
- **Environment Variables**: The commands are run with `NIXPKGS_ALLOW_UNFREE=1`
  and `NIXPKGS_ALLOW_INSECURE=1` to allow unfree and insecure packages.
- **Custom Expiration**: The expiration period for expiring generations and
  garbage collection can be customized by setting the `expiration` variable in
  the Makefile.

Example of changing the expiration period to 60 days:

```sh
make expiration=60 days expire
```

These commands simplify the process of managing NixOS and Home Manager
configurations, making it easier to apply, update, and maintain your system
setup.
