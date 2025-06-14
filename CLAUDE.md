# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

- **Build**: `npm run build` - Compiles TypeScript to JavaScript in `lib/` directory
- **Test**: `npm test` - Runs all Playwright tests across browsers
- **Single browser tests**: `npm run ctest` (Chrome), `npm run ftest` (Firefox), `npm run wtest` (WebKit)
- **Lint**: `npm run lint` - Runs ESLint and TypeScript type checking
- **Watch**: `npm run watch` - Compiles TypeScript in watch mode
- **Start MCP server**: `npm run run-server` - Runs the built browser server

## Architecture

This is a Model Context Protocol (MCP) server that provides browser automation through Playwright. The architecture follows these key patterns:

### Core Components

- **Connection Management**: `src/connection.ts` creates MCP connections with browser context factories
- **Server**: `src/server.ts` manages multiple connections and browser lifecycle
- **Context Management**: `src/context.ts` and `src/browserContextFactory.ts` handle browser context creation/cleanup
- **Transport Layer**: Supports both stdio and SSE (Server-Sent Events) transports via `src/transport.ts`

### Tool Architecture

Tools are modularized in `src/tools/` with each file containing related browser capabilities:
- `common.ts` - Core interactions (click, type, hover, drag, select)
- `navigate.ts` - Navigation (go to URL, back, forward)
- `snapshot.ts` - Accessibility snapshots (default mode)
- `vision.ts` - Screenshot-based interactions (vision mode)
- `tabs.ts` - Tab management
- `files.ts` - File uploads
- `pdf.ts` - PDF generation
- `console.ts` - Console message access
- `network.ts` - Network request monitoring
- `testing.ts` - Playwright test generation

Each tool follows the `Tool` interface from `src/tools/tool.ts` with schema validation and capability flags.

### Configuration System

- Config resolution in `src/config.ts` merges CLI args, config files, and defaults
- Supports JSON config files with browser options, server settings, and capability controls
- Browser context factory pattern allows for persistent vs isolated sessions

### Key Design Patterns

- **Accessibility-First**: Default mode uses Playwright's accessibility tree instead of screenshots
- **Modular Capabilities**: Tools are grouped by capability and can be selectively enabled
- **Transport Agnostic**: Works with stdio (MCP clients) or SSE (standalone server)
- **Browser Lifecycle Management**: Automatic cleanup and session management

## Source Structure

- `src/` - TypeScript source files
- `lib/` - Compiled JavaScript output (created by build)
- `tests/` - Playwright test suite
- `cli.js` - Entry point that imports `lib/program.js`
- `index.js` - Main export for programmatic usage

The build process compiles TypeScript from `src/` to `lib/` with ES modules format.