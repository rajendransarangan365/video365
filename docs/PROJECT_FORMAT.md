# Video365 Project Format (.lcprj v2.0)

## 1. Overview
The `.lcprj` file is a JSON-based project manifest that describes the non-destructive editing state of a Video365 project. It is designed to be compatible with both the Kotlin/Compose UI layer and the C++ Render Graph.

## 2. Schema Specification
See `plan.md` for the full JSON structure. Key improvements over v1.0:
*   **Layer-Based Architecture**: Supports parenting and hierarchical transforms.
*   **Animatable Properties**: Every property (position, scale, opacity) supports static values, keyframes (Bezier/Linear), and JS expressions.
*   **Assets vs. Layers**: Media is managed in a global `assets` array, while `layers` in a `composition` reference them by `assetId`.
*   **Render Cache**: Stores metadata about pre-rendered segments to ensure 60fps playback on complex timelines.

## 3. Serialization
*   **Kotlin**: `kotlinx.serialization` is used for high-performance JSON parsing.
*   **C++**: `nlohmann/json` or a custom lightweight parser will ingest the schema to build the Render Graph DAG.

## 4. Path Handling
All URIs are stored as absolute strings. On Android, these usually reference `content://` (SAF) or `file:///` (internal cache/proxy).
