const fs = require('fs');

console.log('🔍 Checking for service account key...');

if (fs.existsSync('./serviceAccountKey.json')) {
  console.log('✅ Service account key found!');
  console.log('📝 You can now run: npm run upload');
} else {
  console.log('❌ Service account key not found!');
  console.log('');
  console.log('📋 To get the service account key:');
  console.log('1. Go to Firebase Console: https://console.firebase.google.com/');
  console.log('2. Select your project');
  console.log('3. Go to Project Settings (gear icon)');
  console.log('4. Click "Service accounts" tab');
  console.log('5. Click "Generate new private key"');
  console.log('6. Download the JSON file');
  console.log('7. Rename it to "serviceAccountKey.json"');
  console.log('8. Place it in the project root directory');
  console.log('');
  console.log('After placing the file, run: npm run upload');
} 