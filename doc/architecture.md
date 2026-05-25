# Architecture Overview

This document outlines how the application is implemented and structured, designed to help new developers quickly understand the codebase.

## 1. Data Flow

The application follows a unidirectional data flow pattern utilizing **Riverpod** for state management.

**`UI (Widgets)` -> `Riverpod (Providers)` -> `Business Logic (StateNotifier)` -> `Models`**

*   **UI (Widgets)**: Observes the state to build the interface and captures user interactions (swipes, taps).
*   **Riverpod (`gameStateProvider`)**: Exposes the state to the UI and provides access to methods that mutate the state, acting as the bridge.
*   **Business Logic (`GameStateNotifier`)**: Contains the core rules of the game (e.g., tile movement, collision detection, merging logic, and game over conditions). It updates the state in response to UI actions.
*   **Models (`BoardState`, `Tile`)**: Immutable data structures representing a snapshot of the game board and individual tiles.

## 2. Implementation Hierarchy

The application is composed of a clear, hierarchical widget tree:

*   **`lib/main.dart`**: The entry point. It wraps the app in a `ProviderScope` (required for Riverpod) and sets up `CubeGame`, which points to `GameScreen` as the starting view.
*   **`lib/ui/game_screen.dart` (`GameScreen`)**: The main layout scaffold. It watches the `gameStateProvider` for changes and triggers rebuilds. It orchestrates the main components:
    *   **`HeaderWidget` (`lib/ui/components/header.dart`)**: Displays the current score, high score, and control buttons (like 'Play Again').
    *   **`GestureDetector`**: Wraps the game board area to capture user input (drag and drop). It reads the `gameStateProvider.notifier` to call methods like `setMoveColumn()` and `dropTile()` based on user gestures.
    *   **`GameBoardWidget` (`lib/ui/components/game_board.dart`)**: Responsible for drawing the grid and layout. It reads the `BoardState` to position and render:
        *   The currently active (falling) tile.
        *   The placed (static) tiles.
        *   The grid boundaries and styling.
        *   It utilizes **`TileWidget` (`lib/ui/components/tile_widget.dart`)** to render the visual representation of individual tiles (colors, text styling based on tile value).

This clean separation ensures that UI components remain dumb and focused on rendering, while the state management handles all complex game mechanics.
