# MS CoreUtils Choco Package

[![Workflow](https://github.com/gsmitheidw/mscoreutils/actions/workflows/publish.yml/badge.svg)](https://github.com/gsmitheidw/mscoreutils/actions/workflows/publish.yml)
![License](https://img.shields.io/badge/license-MIT-green)
![Last Commit](https://img.shields.io/github/last-commit/gsmitheidw/mscoreutils)
![Repo Size](https://img.shields.io/github/repo-size/gsmitheidw/mscoreutils)

<!-- Commented out until approved
![Chocolatey Version](https://img.shields.io/chocolatey/v/mscoreutils)
![Chocolatey Downloads](https://img.shields.io/chocolatey/dt/mscoreutils)
--->

This is a chocolatey package for the public community repo for [MS CoreUtils](https://github.com/microsoft/coreutils)

## Overview

Unix CoreUtils from [CoreUtils](https://github.com/uutils/coreutils) is a modern implementation of 
the GNU Utils in Rust rather than the original C based [CoreUtils](https://www.gnu.org/software/coreutils/). 
MS has repackaged these for compatability in MS Windows environments where possible/relevant.  

It also includes [findutils](https://github.com/uutils/findutils) and [grep](https://github.com/uutils/grep)

Also see: https://learn.microsoft.com/en-us/windows/core-utils/overview


## Automation

This nupkg creation runs as a github action, it pulls metadata from Microsoft's winget manifest daily and pushes
any new release to chocolatey via API key.

```mermaid

flowchart TD

A[GitHub Actions<br/>Daily Run]
--> B[update.ps1]

B --> C[Check latest<br/>Microsoft Coreutils]

C --> D{New version?}

D -->|No| E[Stop]

D -->|Yes| F[Fetch winget<br/>manifest checksum & url]

F --> G[Update nuspec<br/>+ install script]

G --> H[choco pack]

H --> I[choco push]

I --> J[Update .version]

J --> K[Choco Moderation Queue]

```
