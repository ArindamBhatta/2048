# Drop 2048 - Game Architecture

## 1. Overview
This document outlines the architecture for the new "Drop 2048" game, moving away from the classic sliding-grid mechanics to a gravity-based puzzle format. In this variant, tiles containing numbers (2, 4, 8, 16, etc.) drop from the top of the screen. The player controls which column the tile falls into. If a tile lands on or adjacent to a tile of the same value, they merge. A top boundary line dictates the game-over condition.

## 2. Core Mechanics
*   **Tile Spawning:** A new tile spawns at the top of the screen (above the boundary line).
*   **Player Control:** The player swipes horizontally to position the active tile over a specific column, and taps (or swipes down) to drop it.
*   **Gravity:** Once dropped, the tile falls straight down until it hits the floor of the grid or the top of another tile in that column.
*   **Merging:** 
    *   **Vertical:** If a falling tile hits a tile of the same number, they merge into a single tile with double the value (e.g., 8 + 8 = 16).
    *   **Horizontal:** After a tile lands, if the adjacent tile(s) in the neighboring columns have the same value, they merge.
    *   **Chain Reactions:** Merging can create empty space, causing tiles above to fall further. Newly formed tiles can trigger subsequent merges.
*   **Boundary Line (Game Over):** A visible line at the top of the grid. If the stack of tiles in any column remains above this line after all merges settle, the game ends.

## 3. Architecture Pattern
The project will follow a strict layered architecture to ensure separation of concerns, utilizing **Riverpod** for state management and dependency injection. The data flow is strictly unidirectional: **UI Layer -> Riverpod (State/Providers) -> Service/Business Logic Layer -> Model (Data Layer)**.

### 3.1. Models (Data Layer)
Pure data classes representing the core entities.
*   `Tile`: Represents a single block. Contains `id` (unique), `value` (2, 4, 8...), and `position` (row/column coordinates).
*   `BoardState`: Represents the grid state, keeping track of a 2D array or lists of columns containing static tiles, as well as the active falling tile.

### 3.2. Service/Business Logic Layer
Pure Dart classes responsible for the core game rules and logic, independent of Flutter UI and Riverpod state.
*   `GameEngine`: The core engine handling game rules.
    *   `spawnNextTile()`: Generates the next active tile.
    *   `calculateDropLanding(int column)`: Calculates where a tile should stop falling.
    *   `evaluateMerges(BoardState currentState)`: Checks for vertical and horizontal merges and returns the new board state.
    *   `applyGravity(BoardState currentState)`: Pulls tiles down if empty spaces exist below them and returns the updated state.
    *   `checkGameOver(BoardState currentState)`: Validates if any column exceeds the boundary line.

### 3.3. Riverpod (State Management Layer)
Acts as the glue between the UI and the Business Logic. Exposes state to the UI and handles intent from the UI by calling the Business Logic layer.
*   `GameStateNotifier` (or `Notifier`/`AsyncNotifier`): Holds the current `BoardState`.
    *   Exposes methods for the UI to call: `moveActiveTile(int column)`, `dropTile()`.
    *   Internally uses `GameEngine` to calculate the new state and updates itself, which in turn rebuilds the UI.

### 3.4. Views (UI Layer)
*   `GameScreen`: The main scaffold.
*   `HeaderWidget`: Displays the current score, high score, and a preview of the *next* tile.
*   `GameBoardWidget`: A custom widget (e.g., using a Stack) representing the playable area.
    *   `BoundaryLineWidget`: A static visual cue indicating the danger zone.
    *   `StaticTilesLayer`: Renders the tiles that have already landed.
    *   `ActiveTileLayer`: Renders the tile currently being controlled by the player.

## 4. Animation and Physics
Since the game is column-based, we do not strictly need a complex physics engine like Flame or Forge2D. We can achieve this with Flutter's built-in `AnimationController` and `Tween`s:
*   **Fall Animation:** When a tile is dropped, animate its Y-coordinate from the top to the calculated landing row.
*   **Merge Animation:** A quick "pop" scale animation (Scale up to 1.2x, then back to 1.0x) when a merge occurs, along with updating the tile color and number.

## 5. Implementation Roadmap
1.  **State Management Setup:** Initialize the column-based grid data structure.
2.  **UI Layout:** Create the basic layout with columns, boundary line, and score display.
3.  **Active Tile Controls:** Implement horizontal dragging and dropping mechanics.
4.  **Landing & Collision:** Calculate where a tile should stop falling and update the grid state.
5.  **Merge Logic:** Implement the algorithm to find adjacent identical tiles (vertical and horizontal) and execute the merge.
6.  **Chain Reaction & Gravity:** Ensure that when tiles merge horizontally, any unsupported tiles above them fall down.
7.  **Game Over Condition:** Hook up the boundary line check.
8.  **Polish:** Add animations, sounds, and vibrant colors for higher-tier tiles.
