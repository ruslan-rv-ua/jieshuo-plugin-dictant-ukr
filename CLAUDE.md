# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a [JieShuo](https://jieshuo.app/) screen reader plugin for Android, targeting Ukrainian language users. It enables voice dictation into any text editor with automatic punctuation formatting and capitalization.

The plugin is distributed as a `.ppk` file (a renamed zip archive) containing only `src/main.lua`.

## Build

```bash
python build.py
```

Produces `dist/диктант-{version}-uk.ppk` by zipping `src/main.lua`. Version is read from `project.toml`.

## Architecture

**Single-file constraint**: JieShuo plugins must be a single `src/main.lua`. No multi-file `require` is supported. All logic lives in this one file.

**Runtime environment**: The plugin runs inside JieShuo on Android. The following globals are injected by the host:
- `this` — Android `Context`
- `activity` / `service` — JieShuo host object; `service.getText(node)`, `service.setText(node, text)`, `service.speak(text)`, `service.appendSpeak(text)`, `service.isEditView(node)`
- `node` — the currently focused accessibility node
- `import` / `require "import"` — JieShuo's Android API bridge (imports Java/Android classes by name)

**Text processing pipeline** (applied to recognized speech in order):
1. `decodePunctuations()` — maps Ukrainian spoken punctuation words (e.g. "крапка" → `.`) and the capitalize trigger phrase to an internal `~` symbol
2. Prepend existing editor text, or clear it if the utterance starts with `CLEAR_EDITOR_PHRASE` ("диктант")
3. `formatPunctuations()` — removes spaces before `.`, `,`, `?`, `!`, `:`
4. `stripLines()` — trims whitespace from each line
5. `capitalize()` — capitalizes sentence-starts (after `.`, `?`, `!`) and words preceded by `~` (from "з великої"), then removes `~`

**Execution flow**: The script body runs immediately on plugin activation — no entry-point function. It vibrates (if `VIBRATE = true`), checks `service.isEditView(node)`, then calls `startListening()` which registers a `RecognitionListener` and fires Android's speech recognizer.
