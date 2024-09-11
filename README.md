# WasteNot
WasteNot is a Swift-based iOS application designed to help users manage their Shopping list with Walmart redirection and sharing lists with others, food inventory, reduce waste, and get recipe recommendations based on ingredients nearing their expiration date and waste analysis.

## Table of Contents
1. [Features](#features)
2. [Tech Stack](#tech-stack)
3. [Firebase Setup](#firebase-setup)
4. [Edamam API](#edamam-api)
5. [How to Run the App](#how-to-run-the-app)

---

## Features


### Shopping List
Add items to your shopping list, track quantities, and categorize items (e.g., dairy, meat, snacks), and Walmart redirection for every item.

### Food Inventory
Keep track of food items in your inventory with expiration dates and receive notifications.

### Notifications
Get reminders for items that are about to expire, including 24-hour reminders and instant notifications.

### Recipe Recommendations
Fetch recipes based on the ingredients (expiring items) you have using the Edamam API.

### Analytics
View detailed analytics for expired items, including a graphical representation of items that expired in the current month.

### PDF Export
Generate and share a PDF of your shopping list via various platforms (email, WhatsApp, etc.).

### Firestore Integration
Sync shopping list data across devices using Firebase Firestore.

---

## Tech Stack
- **Swift (SwiftUI)**: Uses SwiftUI for the app’s user interface.
- **Firebase Firestore**: Cloud Firestore is used to store and retrieve shopping list data.
- **Edamam API**: Integrated to provide recipe recommendations based on available food items.
- **UserNotifications**: Push notifications for item expiration and reminders.
- **PDFKit**: For generating and exporting shopping lists as PDFs.
- **Charts Framework (iOS 16+)**: Used to create graphs in the Analytics view.

---

## Firebase Setup
1. You will need to configure Firebase for iOS and download the `GoogleService-Info.plist`.
2. Add the plist to your Xcode project to enable Firestore and other Firebase services.

---

## Edamam API
To use the recipe recommendation feature, sign up on [Edamam](https://developer.edamam.com/) and get your `API_KEY` and `APP_ID`. Replace these values in the project with your credentials.

---

## How to Run the App
1. Clone the repository:
   ```bash
   git clone https://github.com/igurvir/WasteNot.git
