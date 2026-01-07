#!/usr/bin/env swift

/**
 * App Icon Generator for macOS
 * 
 * This script generates app icons for the ChatGPT macOS app.
 * It creates icons in all required sizes for the App Store.
 * 
 * Usage: swift scripts/generate_app_icons.swift <source_image>
 * 
 * The source image should be at least 1024x1024 pixels.
 */

import Foundation
import AppKit

// Icon sizes for macOS app
let iconSizes: [(size: Int, scale: Int, name: String)] = [
    (16, 1, "icon_16x16"),
    (16, 2, "icon_16x16@2x"),
    (32, 1, "icon_32x32"),
    (32, 2, "icon_32x32@2x"),
    (128, 1, "icon_128x128"),
    (128, 2, "icon_128x128@2x"),
    (256, 1, "icon_256x256"),
    (256, 2, "icon_256x256@2x"),
    (512, 1, "icon_512x512"),
    (512, 2, "icon_512x512@2x")
]

func printUsage() {
    print("""
    ChatGPT App Icon Generator
    ==========================
    
    Usage: swift generate_app_icons.swift <source_image>
    
    The source image should be at least 1024x1024 pixels.
    Icons will be generated in the Assets.xcassets folder.
    
    App URL: https://chatgpt.com/
    
    Required sizes:
    """)
    
    for icon in iconSizes {
        let actualSize = icon.size * icon.scale
        print("  - \(icon.name).png (\(actualSize)x\(actualSize))")
    }
}

func generateIcons(from sourcePath: String) {
    guard let image = NSImage(contentsOfFile: sourcePath) else {
        print("Error: Could not load image from \(sourcePath)")
        return
    }
    
    let outputDir = "ChatGPT/ChatGPT/Assets.xcassets/AppIcon.appiconset"
    
    do {
        try FileManager.default.createDirectory(
            atPath: outputDir,
            withIntermediateDirectories: true
        )
    } catch {
        print("Error creating output directory: \(error)")
        return
    }
    
    for icon in iconSizes {
        let actualSize = icon.size * icon.scale
        let outputPath = "\(outputDir)/\(icon.name).png"
        
        if let resizedImage = resizeImage(image, to: NSSize(width: actualSize, height: actualSize)),
           let data = resizedImage.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: data),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            do {
                try pngData.write(to: URL(fileURLWithPath: outputPath))
                print("Generated: \(outputPath)")
            } catch {
                print("Error writing \(outputPath): \(error)")
            }
        }
    }
    
    print("\nDone! Icons generated in \(outputDir)")
}

func resizeImage(_ image: NSImage, to size: NSSize) -> NSImage? {
    let newImage = NSImage(size: size)
    newImage.lockFocus()
    image.draw(
        in: NSRect(origin: .zero, size: size),
        from: NSRect(origin: .zero, size: image.size),
        operation: .copy,
        fraction: 1.0
    )
    newImage.unlockFocus()
    return newImage
}

// Main
if CommandLine.arguments.count < 2 {
    printUsage()
} else {
    generateIcons(from: CommandLine.arguments[1])
}
