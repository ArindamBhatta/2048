# 🎮 Gravity 2048: A Physics-Inspired Flutter Game

[![Flutter Version](https://img.shields.io/badge/Flutter-3.0%2B-blue.svg?style=flat-for-the-badge&logo=flutter)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/State--Management-Riverpod-red.svg?style=flat-for-the-badge)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat-for-the-badge)](LICENSE)

A gorgeous, highly-optimized mobile puzzle game built in **Flutter**. It introduces an innovative **Gravity-Based Mode** where players slide and drop tiles into a virtual bucket, merging matching numbers to reach the ultimate 2048 tile.

Unlike most mobile games that rely on heavy game engines like *Flame*, this project was designed from the ground up to utilize **Flutter's native animation system** (`AnimatedPositioned` and explicit curves) to guarantee smooth 60 FPS performance, a featherweight installation footprint, and high-fidelity transitions.

---

## 🎥 Gameplay Preview



---

## ✨ Key Features

### 🌌 Gravity Mode (Columns Drop & Merge)
Experience a physics-infused twist on the classic 2048 formula:
*   **Virtual Bucket Coordinates**: Guide descending tiles horizontally within a virtual coordinate space (`bucketWidth = 400.0`, `bucketHeight = 600.0`) by dragging.
*   **Landing Detection Physics**: An intelligent landing resolver system dynamically calculates falling paths and final settled Y positions.
*   **Recursive Chain Reactions**: Dropped tiles automatically cascade and merge both horizontally and vertically, setting off satisfying chain-reaction mergers until the board stabilizes.
*   **Boundary Warning System**: If tiles stack up and cross the warning line threshold (`warningLineY = 500.0`), it's game over!

---

## 🏗️ Architectural Overview

The application is architected around a strict **unidirectional data flow** ensuring zero side-effects and extreme testability:

```mermaid
graph TD
    UI[Flutter Widgets: GameBoardWidget, HeaderWidget, TileWidget]
    State[Riverpod Notifier: GameNotifier]
    Engine[Business Logic: GameEngine]
    Model[Immutable State: BoardState & Tile]

    UI -- 1. Dispatches Interaction Events --> State
    State -- 2. Delegates Merges / Physics to --> Engine
    Engine -- 3. Computes & Returns --> Model
    Model -- 4. Notifies Change & Rebuilds UI --> UI
```

### Core Architecture Components:
1.  **UI layer (`lib/ui`)**: Responsive Flutter widget structure including a virtual board, header dashboards, and custom tile elements.
2.  **State Management (`lib/state`)**: Powered by **Riverpod `NotifierProvider`**, handling granular events like `setMoveX()`, `dropTile()`, and `resetGame()`.
3.  **Logical Solver (`lib/services/game_engine.dart`)**: Mathematical solver that runs structural and gravity-based grid validations (recursive gravity collapses, horizontal/vertical merging, landing lookups).
4.  **Immutable Models (`lib/models`)**: Built utilizing pure immutable data classes with deep cloning capability (`copyWith`), ensuring robust state transitions.

---

## ⚡ Custom Native Animation Engine

Instead of bundling heavy game engine overhead, this project achieves premium fluid animations using Flutter's native framework:
*   **Explicit Animations**: Handles fine-grained control over tile transitions, drop acceleration, and scale-up merges.
*   **Lag-Free Rendering**: Uses native platform composition ensuring animations run directly on the thread without bottlenecking.
*   **Dynamic Layout Calculations**: Employs `LayoutBuilder` coordinates to calculate exact column boundary boxes on the fly, rendering drags extremely precise.

---

## 🛠️ Tech Stack & Dependencies

*   **Framework**: [Flutter](https://flutter.dev) (Dart SDK `>=3.0.3`)
*   **State Management**: [Riverpod (3.x)](https://riverpod.dev) for reactive state updates.
*   **Gesture Recognizer**: Native drag detection via `GestureDetector`.
*   **Asset Bundler**: Explicit asset and standard vector setups.

---

## 🚀 Getting Started & Setup

### Prerequisites
Make sure you have the [Flutter SDK installed](https://docs.flutter.dev/get-started/install) on your system.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/gravity-2048.git
    cd gravity-2048
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Launch the application in Dev mode:**
    ```bash
    flutter run
    ```

### Production Build

*   **Build Android APK:**
    ```bash
    flutter build apk --release
    ```
*   **Build iOS App Bundle:**
    ```bash
    flutter build ipa --release
    ```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
