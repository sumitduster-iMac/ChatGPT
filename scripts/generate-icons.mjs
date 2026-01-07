#!/usr/bin/env node

/**
 * Icon Generator for ChatGPT Desktop App
 * Generates app icons in various formats for different platforms
 * 
 * Usage: node scripts/generate-icons.mjs
 */

import sharp from 'sharp';
import pngToIco from 'png-to-ico';
import { writeFile, mkdir, readFile } from 'fs/promises';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { execSync } from 'child_process';

const __dirname = dirname(fileURLToPath(import.meta.url));
const rootDir = join(__dirname, '..');
const assetsDir = join(rootDir, 'assets');

// Icon sizes needed for different platforms
const macSizes = [16, 32, 64, 128, 256, 512, 1024];
const winSizes = [16, 32, 48, 64, 128, 256];
const linuxSize = 512;

async function generateIcons() {
  console.log('🎨 Generating app icons...\n');

  // Ensure assets directory exists
  await mkdir(assetsDir, { recursive: true });

  // Read the SVG source
  const svgPath = join(assetsDir, 'chatgpt-logo.svg');
  let svgBuffer;
  
  try {
    svgBuffer = await readFile(svgPath);
  } catch {
    // Fall back to root icon.svg
    svgBuffer = await readFile(join(rootDir, 'icon.svg'));
  }

  // Generate PNG at largest size first (1024x1024)
  console.log('📐 Generating base PNG (1024x1024)...');
  const basePng = await sharp(svgBuffer)
    .resize(1024, 1024, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } })
    .png()
    .toBuffer();

  // Save base PNG
  await writeFile(join(assetsDir, 'icon-1024.png'), basePng);

  // Generate Linux icon (512x512 PNG)
  console.log('🐧 Generating Linux icon (512x512 PNG)...');
  const linuxPng = await sharp(basePng).resize(linuxSize, linuxSize).png().toBuffer();
  await writeFile(join(assetsDir, 'icon.png'), linuxPng);
  console.log('   ✓ assets/icon.png');

  // Generate Windows icon sizes
  console.log('🪟 Generating Windows icon...');
  const winPngs = await Promise.all(
    winSizes.map(async (size) => {
      return sharp(basePng).resize(size, size).png().toBuffer();
    })
  );
  
  // Create ICO file
  const icoBuffer = await pngToIco(winPngs);
  await writeFile(join(assetsDir, 'icon.ico'), icoBuffer);
  console.log('   ✓ assets/icon.ico');

  // Generate macOS iconset
  console.log('🍎 Generating macOS icons...');
  const iconsetDir = join(assetsDir, 'icon.iconset');
  await mkdir(iconsetDir, { recursive: true });

  // macOS requires specific naming: icon_16x16.png, icon_16x16@2x.png, etc.
  const macIconFiles = [
    { size: 16, name: 'icon_16x16.png' },
    { size: 32, name: 'icon_16x16@2x.png' },
    { size: 32, name: 'icon_32x32.png' },
    { size: 64, name: 'icon_32x32@2x.png' },
    { size: 128, name: 'icon_128x128.png' },
    { size: 256, name: 'icon_128x128@2x.png' },
    { size: 256, name: 'icon_256x256.png' },
    { size: 512, name: 'icon_256x256@2x.png' },
    { size: 512, name: 'icon_512x512.png' },
    { size: 1024, name: 'icon_512x512@2x.png' },
  ];

  for (const { size, name } of macIconFiles) {
    const png = await sharp(basePng).resize(size, size).png().toBuffer();
    await writeFile(join(iconsetDir, name), png);
  }

  // Try to create .icns file (only works on macOS)
  try {
    execSync(`iconutil -c icns "${iconsetDir}" -o "${join(assetsDir, 'icon.icns')}"`, { stdio: 'pipe' });
    console.log('   ✓ assets/icon.icns');
  } catch {
    console.log('   ⚠ iconutil not available (macOS only) - .icns will be created during build');
    // electron-builder can create icns from iconset or png
  }

  console.log('\n✅ Icon generation complete!');
  console.log('\nGenerated files:');
  console.log('  - assets/icon.png (Linux)');
  console.log('  - assets/icon.ico (Windows)');
  console.log('  - assets/icon.iconset/ (macOS iconset)');
  if (process.platform === 'darwin') {
    console.log('  - assets/icon.icns (macOS)');
  }
}

generateIcons().catch(console.error);
