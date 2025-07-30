# Categories Upload Script

This script uploads categories to the `agent_categories` collection in Firestore for the Hushh Agent App.

## Prerequisites

1. **Firebase Service Account Key**: You need to download your Firebase service account key from the Firebase Console:
   - Go to Firebase Console → Project Settings → Service Accounts
   - Click "Generate new private key"
   - Download the JSON file and save it as `serviceAccountKey.json` in the project root

2. **Node.js**: Make sure you have Node.js installed on your system

## Installation

1. Install dependencies:
   ```bash
   npm install
   ```

## Usage

1. Make sure you have the `serviceAccountKey.json` file in the project root
2. Run the upload script:
   ```bash
   npm run upload
   ```

## Categories Included

The script uploads the following categories:

### Fashion & Apparel
- Fashion & Apparel
- Jewelry & Watches
- Beauty & Personal Care
- Footwear
- Handbags & Bags

### Technology & Electronics
- Technology & Electronics
- Smartphones
- Computers & Laptops
- Gaming
- Audio & Music
- Cameras & Photography

### Home & Living
- Home & Living
- Kitchen & Dining
- Garden & Outdoor

### Sports & Fitness
- Sports & Fitness
- Outdoor Recreation

### Other Categories
- Automotive
- Books & Media
- Toys & Games
- Health & Wellness
- Pet Supplies
- Baby & Kids
- Office & Business
- Art & Crafts
- Musical Instruments
- Food & Beverages
- Travel & Tourism

## Firestore Structure

Each category document will have the following structure:
```json
{
  "name": "Category Name",
  "description": "Category description",
  "isActive": true,
  "createdAt": "server timestamp",
  "updatedAt": "server timestamp"
}
```

## Troubleshooting

- **Service Account Key Error**: Make sure the `serviceAccountKey.json` file is in the project root and has the correct permissions
- **Firestore Permission Error**: Ensure your service account has write permissions to the `agent_categories` collection
- **Network Error**: Check your internet connection and Firebase project configuration

## Alternative: Manual Upload

If you prefer to upload categories manually through the Firebase Console:

1. Go to Firebase Console → Firestore Database
2. Create a new collection called `agent_categories`
3. Add documents with the structure shown above
4. Use the categories list from this README as a reference 