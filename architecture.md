# Drop 2048 — Required Architectural Corrections

The current implementation direction is incorrect because it still treats the game like classic 2048 grid movement.

This game is NOT a matrix-transform puzzle.

It is:

* a deterministic falling-object simulation
* with merge resolution
* cascade processing
* and gravity stabilization

The architecture must be redesigned around an event-resolution pipeline.

---

# CRITICAL DESIGN CORRECTIONS

## 1. STOP USING ROW-FIRST THINKING

Current wrong mental model:

* board[row][column]
* move all tiles
* transform matrix

This is incorrect for Drop 2048.

Correct mental model:

* columns are vertical stacks
* only one active tile exists at a time
* tiles fall downward
* merges occur after collision resolution

Rows are only a rendering concept.

Internally, the board should behave like:

```dart
List<List<Tile>> columns;
```

Example:

```dart
columns[0] = [2, 4, 8];
columns[1] = [2];
columns[2] = [];
```

This simplifies:

* gravity
* collision
* landing
* merge resolution
* cascades

---

# 2. ACTIVE TILE MUST BE SEPARATE FROM BOARD

Do NOT insert falling tile into board state before landing.

WRONG:

```dart
board.tiles.add(activeTile)
```

CORRECT:

```dart
class BoardState {
  List<List<Tile>> columns;
  Tile? activeTile;
}
```

The active tile is temporary simulation state.

Only commit it after landing resolution.

---

# 3. REMOVE PIXEL POSITION FROM CORE STATE

Core state must NEVER store:

* x
* y
* pixelOffset
* animation values

Core state must only store logical state:

```dart
class Tile {
  final int id;
  final int value;
  final int column;
  final int stackIndex;
}
```

UI computes pixel positions separately.

---

# 4. GAME ENGINE MUST BECOME PIPELINE-BASED

Current likely issue:

* giant GameEngine class
* direct mutation
* merge while iterating
* UI-driven logic

This causes instability.

The engine must become deterministic pipeline processing.

Required architecture:

```text
GameEngine
 ├── DropResolver
 ├── MergeDetector
 ├── MergeExecutor
 ├── GravityResolver
 └── GameOverResolver
```

Each resolver performs ONE responsibility only.

---

# 5. NEVER MERGE DURING ITERATION

This is a major bug source.

WRONG:

```dart
for (...) {
   if (sameValue) {
      mergeImmediately();
   }
}
```

This causes:

* skipped tiles
* double merges
* inconsistent cascades

Correct approach:

1. detect merges
2. queue merge operations
3. apply merges afterward

Required structure:

```dart
class MergeOperation {
  final Tile sourceA;
  final Tile sourceB;
  final int resultValue;
  final int targetColumn;
}
```

Pipeline:

```text
detect
-> queue
-> resolve
-> apply gravity
-> repeat
```

---

# 6. CASCADE LOOP IS THE CORE SYSTEM

After every merge:

* empty spaces appear
* upper tiles fall
* new merges may become possible

Engine MUST repeatedly stabilize board state.

Required loop:

```dart
while (true) {
   final merges = detectMerges();

   if (merges.isEmpty) {
      break;
   }

   applyMerges(merges);

   applyGravity();
}
```

This stabilization loop is the heart of the game.

---

# 7. PLAYER INPUT MUST LOCK DURING RESOLUTION

Once drop starts:

* disable movement
* disable additional drops

Otherwise race conditions occur.

Required phases:

```text
SPAWN
-> CONTROL
-> DROP
-> RESOLVE
-> STABILIZE
-> NEXT TURN
```

Only CONTROL phase accepts input.

---

# 8. UI MUST NOT DRIVE GAME LOGIC

Animations are visual only.

Logic calculates final board instantly.

Then UI animates toward resulting state.

WRONG:

* animation updates board state

CORRECT:

* board state updates instantly
* UI interpolates visuals afterward

---

# 9. GRAVITY MUST BE DETERMINISTIC

Do NOT use real physics engines.

Do NOT use:

* Forge2D
* Flame physics
* rigid body simulation

This game needs:

* fake deterministic gravity
* exact predictable results

Landing position should be mathematically calculated:

```dart
landingIndex = columns[column].length;
```

Not simulated physically.

---

# 10. MERGE RULES MUST BE EXPLICIT

Define exact merge policy.

Recommended:

## Simultaneous Merge Resolution

Meaning:

* scan entire board first
* collect all merge operations
* execute together

Never mutate during scan.

This prevents inconsistent behavior like:

```text
2 2 2
```

producing random outcomes depending on iteration order.

---

# 11. RECOMMENDED CORE FOLDER STRUCTURE

```text
core/
 ├── models/
 │    ├── tile.dart
 │    ├── board_state.dart
 │    └── merge_operation.dart
 │
 ├── engine/
 │    ├── game_engine.dart
 │    ├── drop_resolver.dart
 │    ├── merge_detector.dart
 │    ├── merge_executor.dart
 │    ├── gravity_resolver.dart
 │    └── game_over_resolver.dart
 │
 ├── providers/
 │    └── game_state_notifier.dart
 │
 └── ui/
```

---

# 12. FINAL ARCHITECTURAL GOAL

The game should operate like:

```text
spawn tile
-> player selects column
-> tile lands
-> detect merges
-> execute merges
-> apply gravity
-> repeat until stable
-> check game over
-> spawn next tile
```

NOT like classic 2048 matrix movement.

This is a state-resolution simulation pipeline, not a swipe-grid puzzle.