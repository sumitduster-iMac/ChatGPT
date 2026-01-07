#!/usr/bin/env node

/**
 * Icon Generator for ChatGPT Desktop App
 * Generates app icons in various formats for different platforms
 * 
 * Usage: node scripts/generate-icons.mjs
 */

import sharp from 'sharp';
import pngToIco from 'png-to-ico';
import { writeFile, mkdir } from 'fs/promises';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { execSync } from 'child_process';

const __dirname = dirname(fileURLToPath(import.meta.url));
const rootDir = join(__dirname, '..');
const assetsDir = join(rootDir, 'assets');

// Official ChatGPT icon SVG (expanded - no xlink:href for compatibility)
const chatGptIconSvg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 2406 2406" width="1024" height="1024">
  <path d="M1 578.4C1 259.5 259.5 1 578.4 1h1249.1c319 0 577.5 258.5 577.5 577.4V2406H578.4C259.5 2406 1 2147.5 1 1828.6V578.4z" fill="#10a37f"/>
  <g fill="#fff">
    <path d="M1107.3 299.1c-197.999 0-373.9 127.3-435.2 315.3L650 743.5v427.9c0 21.4 11 40.4 29.4 51.4l344.5 198.515V833.3h.1v-27.9L1372.7 604c33.715-19.52 70.44-32.857 108.47-39.828L1447.6 450.3C1361 353.5 1237.1 298.5 1107.3 299.1zm0 117.5-.6.6c79.699 0 156.3 27.5 217.6 78.4-2.5 1.2-7.4 4.3-11 6.1L952.8 709.3c-18.4 10.4-29.4 30-29.4 51.4V1248l-155.1-89.4V755.8c-.1-187.099 151.601-338.9 339-339.2z"/>
    <path d="M1107.3 299.1c-197.999 0-373.9 127.3-435.2 315.3L650 743.5v427.9c0 21.4 11 40.4 29.4 51.4l344.5 198.515V833.3h.1v-27.9L1372.7 604c33.715-19.52 70.44-32.857 108.47-39.828L1447.6 450.3C1361 353.5 1237.1 298.5 1107.3 299.1zm0 117.5-.6.6c79.699 0 156.3 27.5 217.6 78.4-2.5 1.2-7.4 4.3-11 6.1L952.8 709.3c-18.4 10.4-29.4 30-29.4 51.4V1248l-155.1-89.4V755.8c-.1-187.099 151.601-338.9 339-339.2z" transform="rotate(60 1203 1203)"/>
    <path d="M1107.3 299.1c-197.999 0-373.9 127.3-435.2 315.3L650 743.5v427.9c0 21.4 11 40.4 29.4 51.4l344.5 198.515V833.3h.1v-27.9L1372.7 604c33.715-19.52 70.44-32.857 108.47-39.828L1447.6 450.3C1361 353.5 1237.1 298.5 1107.3 299.1zm0 117.5-.6.6c79.699 0 156.3 27.5 217.6 78.4-2.5 1.2-7.4 4.3-11 6.1L952.8 709.3c-18.4 10.4-29.4 30-29.4 51.4V1248l-155.1-89.4V755.8c-.1-187.099 151.601-338.9 339-339.2z" transform="rotate(120 1203 1203)"/>
    <path d="M1107.3 299.1c-197.999 0-373.9 127.3-435.2 315.3L650 743.5v427.9c0 21.4 11 40.4 29.4 51.4l344.5 198.515V833.3h.1v-27.9L1372.7 604c33.715-19.52 70.44-32.857 108.47-39.828L1447.6 450.3C1361 353.5 1237.1 298.5 1107.3 299.1zm0 117.5-.6.6c79.699 0 156.3 27.5 217.6 78.4-2.5 1.2-7.4 4.3-11 6.1L952.8 709.3c-18.4 10.4-29.4 30-29.4 51.4V1248l-155.1-89.4V755.8c-.1-187.099 151.601-338.9 339-339.2z" transform="rotate(180 1203 1203)"/>
    <path d="M1107.3 299.1c-197.999 0-373.9 127.3-435.2 315.3L650 743.5v427.9c0 21.4 11 40.4 29.4 51.4l344.5 198.515V833.3h.1v-27.9L1372.7 604c33.715-19.52 70.44-32.857 108.47-39.828L1447.6 450.3C1361 353.5 1237.1 298.5 1107.3 299.1zm0 117.5-.6.6c79.699 0 156.3 27.5 217.6 78.4-2.5 1.2-7.4 4.3-11 6.1L952.8 709.3c-18.4 10.4-29.4 30-29.4 51.4V1248l-155.1-89.4V755.8c-.1-187.099 151.601-338.9 339-339.2z" transform="rotate(240 1203 1203)"/>
    <path d="M1107.3 299.1c-197.999 0-373.9 127.3-435.2 315.3L650 743.5v427.9c0 21.4 11 40.4 29.4 51.4l344.5 198.515V833.3h.1v-27.9L1372.7 604c33.715-19.52 70.44-32.857 108.47-39.828L1447.6 450.3C1361 353.5 1237.1 298.5 1107.3 299.1zm0 117.5-.6.6c79.699 0 156.3 27.5 217.6 78.4-2.5 1.2-7.4 4.3-11 6.1L952.8 709.3c-18.4 10.4-29.4 30-29.4 51.4V1248l-155.1-89.4V755.8c-.1-187.099 151.601-338.9 339-339.2z" transform="rotate(300 1203 1203)"/>
  </g>
</svg>`;

async function generateIcons() {
  console.log('🎨 Generating app icons...\n');

  // Ensure assets directory exists
  await mkdir(assetsDir, { recursive: true });

  // Generate PNG at largest size first (1024x1024)
  console.log('📐 Generating base PNG (1024x1024)...');
  const basePng = await sharp(Buffer.from(chatGptIconSvg))
    .resize(1024, 1024, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } })
    .png()
    .toBuffer();

  // Save base PNG
  await writeFile(join(assetsDir, 'icon-1024.png'), basePng);

  // Generate Linux icon (512x512 PNG)
  console.log('🐧 Generating Linux icon (512x512 PNG)...');
  const linuxPng = await sharp(basePng).resize(512, 512).png().toBuffer();
  await writeFile(join(assetsDir, 'icon.png'), linuxPng);
  console.log('   ✓ assets/icon.png');

  // Generate Windows icon sizes
  console.log('🪟 Generating Windows icon...');
  const winSizes = [16, 32, 48, 64, 128, 256];
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
  }

  console.log('\n✅ Icon generation complete!');
  console.log('\nGenerated files:');
  console.log('  - assets/icon.png (Linux)');
  console.log('  - assets/icon.ico (Windows)');
  console.log('  - assets/icon.iconset/ (macOS iconset)');
}

generateIcons().catch(console.error);
