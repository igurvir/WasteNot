
# WasteNot
WasteNot is a Swift-based iOS application designed to help users manage their Shopping list with Walmart redirection and sharing lists with others, food inventory, reduce waste, and get **recipes based on the ingredients (expiring items)** nearing their expiration date and waste analysis of expired items.

## Table of Contents
1. [Features](#features)
2. [Tech Stack](#tech-stack)
3. [Firebase Setup](#firebase-setup)
4. [Edamam API](#edamam-api)
5. [User Guide](#user-guide)
   




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




## User Guide


## Shopping List
---<img width="300" alt="shopping-list" src="https://github.com/user-attachments/assets/26151005-2b3a-42fd-8d91-6590ef79dcee">


The Shopping List feature allows users to add items by specifying an item name, quantity, and category (Dairy, Meat, Fruit, Snacks, or Other). The items get automatically sorted into their respective categories and gets stored in the firebase database 

### Add Button (+): 
Allows users to add items to the shopping list after inputting the name, quantity, and category.
### Walmart Redirection (Chain Icon): 
Redirects users to the Walmart website where they can search for and purchase the listed item.
### Check Circle: 
Users can mark items as purchased by checking this option. Checked items are visually indicated and excluded from shared lists.
### Edit Button (Pencil Icon):
Allows users to edit the item details (name, quantity, or category).

At the top of the shopping list:

### Share:
Generates a PDF of the shopping list, excluding items marked as purchased, and allows users to share it via various platforms.
### Delete Purchased: 
Deletes all the items that have been checked (purchased) from the shopping list.


## Food Inventory

<img width="472" alt="Screenshot 2024-09-11 at 6 45 27 PM" src="https://github.com/user-attachments/assets/43352404-5754-4d3e-a0d9-5eaeec1f702c">

The Food Inventory feature helps users track items they have added, along with their expiration dates. The following functionalities are provided:

### Add Button (+): 
Allows users to add an item to the inventory and specify the item's expiration date.
### Book Button:
Opens up personalized recipe recommendations based on the items currently in the inventory.
### Notifications:
Users receive a notification when the item is successfully added, and they will also get a reminder 24 hours before the item is about to expire.
### Expired Items: 
Items that have expired are highlighted in red.
### Search:
Users can search for specific items in the inventory.
### Sorting & Filtering:
Sort by Name: Sorts the items alphabetically by their name.
Sort by Expiry Date: Sorts the items by their expiration date.
Filter Expiring Soon: Users can filter the list to only show items that are close to their expiration date.
### Delete Button:
Deletes all items in the inventory.


## Recipe Recommendation

<img width="474" alt="Screenshot 2024-09-11 at 6 47 09 PM" src="https://github.com/user-attachments/assets/76bfda77-fd96-4cac-afd7-b553580ccc39">


The Book Icon in the Food Inventory section opens up a personalized recipe recommendation page. 
This page suggests recipes based on the items that are currently expiring in the user's inventory.

### Dynamic Recipe Suggestions: 
The list of recipes is dynamically generated, meaning that each time the user clicks the book icon, new recipe suggestions are provided.
### Recipe Links: 
The user can click on either the recipe name or the "Open Recipe" URL to get redirected to the detailed recipe page.
### Fresh Suggestions: 
Every time the user accesses this section, they receive new and varied recipe recommendations for the expiring items, allowing for a diverse range of ideas.


