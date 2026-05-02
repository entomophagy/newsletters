# Copilot Instructions

## Build, test, and lint

This repository does not have a build system, automated test suite, or linter configuration.

| Task | Command |
| --- | --- |
| Refresh newsletter PDFs | `bash downloadPdf.sh` |
| Rename PDFs from extracted titles | `./renamePdfs.swift [path/to/file.pdf]` |
| Run a single test | Not available |
| Run full test suite | Not available |
| Run linter | Not available |

`downloadPdf.sh` must be run from the repository root. It depends on `wget` and performs a destructive refresh by deleting the current `*.pdf` files before moving the newly downloaded files into place and renaming them from the first-page title text.

## High-level architecture

This is a flat artifact repository, not an application codebase. The root directory is the data store: each tracked PDF is a newsletter file downloaded from `https://www.entomophagy.or.jp/newsletter`.

The only workflow logic lives in `downloadPdf.sh` and `renamePdfs.swift`. The download script mirrors the upstream newsletter page with `wget --recursive --accept .pdf`, removes the currently tracked PDFs from the repo root, moves newly downloaded PDFs from `www.entomophagy.or.jp/_files/ugd/` into the root, deletes the temporary mirrored directory, then runs the Swift renamer. The renamer uses PDFKit to read the first page and normalizes filenames to the visible newsletter or article title; when given a file path argument it renames only that PDF in place. In practice, most commits are binary file refreshes rather than source changes.

## Key conventions

- Keep newsletter PDFs at the repository root. Do not reorganize them into subdirectories unless the repository structure is intentionally being redesigned.
- Normalize filenames to the visible newsletter or article title instead of keeping the hashed upstream download names.
- Treat `downloadPdf.sh` as the source of truth for refreshes. If the update flow changes, keep the mirror-download -> replace-root-PDFs -> cleanup sequence coherent.
- Run refreshes from the repo root so the relative paths in `downloadPdf.sh` resolve correctly.
- Avoid leaving behind temporary mirror output such as `www.entomophagy.or.jp/`; the repo convention is that only the tracked PDFs and helper script live at the top level.
- Most meaningful changes in this repo are additions, removals, or replacements of PDF binaries. Text edits are usually limited to the refresh script or repository metadata such as this file.
