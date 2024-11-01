# Yama Bird

Yama Bird is a Flappy Bird-inspired iOS game where players tap to keep the bird character airborne and navigate through gaps between pipes. This project was developed in Swift using SpriteKit, custom sounds, and a simple high score system.

## Table of Contents

- [Demo](#demo)
- [Features](#features)
- [Getting Started](#getting-started)
- [How to Play](#how-to-play)
- [Technologies](#technologies)
- [Credits](#credits)
- [License](#license)

---

## Demo

[(https://www.youtube.com/shorts/N8Hu7E-QcB4)]

## Features

- **Simple One-Tap Controls**: Tap to make the bird jump and avoid pipes.
- **Game Sounds**: Includes sounds for flapping, passing pipes, and game over.
- **High Score Tracking**: The highest score is saved locally.
- **Smooth Physics**: The bird’s tilt and movement are adjusted for smooth gameplay.

## Getting Started

Follow these steps to set up and run Yama Bird on your iOS device or simulator:

### Prerequisites

- **Xcode**: Make sure you have Xcode installed (version 12.0 or later recommended).
- **iOS Device or Simulator**: You can run the app on a physical device or within the iOS Simulator in Xcode.

### Installation Instructions

1. **Clone the Repository**:
   - Open Terminal.
   - Clone this repository to your local machine using:
     ```bash
     git clone https://github.com/username/YamaBird.git
     ```
   
2. **Open the Project in Xcode**:
   - Navigate to the project folder:
     ```bash
     cd YamaBird
     ```
   - Open the Xcode project by double-clicking on `YamaBird.xcodeproj` or by running:
     ```bash
     open YamaBird.xcodeproj
     ```
   
3. **Build the Project**:
   - In Xcode, select your target device (iOS simulator or physical device) from the top toolbar.
   - Click the **Run** button (or press `Command + R`) to build and launch the app.

4. **Allow Permissions**:
   - If prompted, grant any necessary permissions (e.g., sound access) to ensure the game runs smoothly.

### Optional: Running on a Physical iOS Device

To run Yama Bird on an actual iOS device:
1. Connect your iPhone to your Mac.
2. In Xcode, select your iPhone from the list of available devices.
3. Ensure your Apple developer account is added in Xcode to allow signing.
4. Click **Run** to build and install the app on your device.

## How to Play

- **Objective**: Keep the bird flying by tapping the screen to navigate through gaps in the pipes without crashing.
- **Scoring**: Earn a point each time you successfully pass between a set of pipes.
- **High Score**: Your highest score is saved and displayed at the top of the screen.

## Technologies

- **Swift**: The programming language used to build the game.
- **SpriteKit**: The 2D game engine framework used for handling graphics and physics.
- **UIKit**: Used for the loading screen and transitioning between scenes.

## Credits

- **Developer**: Andrew Yamasaki
- **Game Assets**: Custom assets created for the project (or list sources if assets were downloaded).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
