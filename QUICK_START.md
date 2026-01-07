# Quick Start Guide

## Electron App (Cross-Platform)

### Prerequisites
- Node.js 18+ installed
- npm or yarn

### Running the App
```bash
npm install
npm start
```

### Building for Distribution
```bash
# Build for your current platform
npm run build

# Build for specific platforms
npm run build:mac
npm run build:win
npm run build:linux
```

## macOS Native App (Swift)

### Prerequisites
- macOS 13.0+
- Xcode 15+

### Building
1. Open `ChatGPT/ChatGPT.xcodeproj` in Xcode
2. Select your development team for signing
3. Build and run (⌘R)

## URL Configuration

The app loads **https://chatgpt.com/** by default.
