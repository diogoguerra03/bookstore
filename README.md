# Book Store XPTO 📚

A mobile library app developed in Flutter, where users can explore a wide collection of books, view detailed information about each book, and add their favorites. The app consumes an external API to fetch book data, providing a smooth experience for searching and browsing through categories.

## Main Features:

- 🔍 **Book Search**: Search by name, genre, or other criteria.
- 📖 **Book Details**: Access synopses, author details, and other book-specific information.
- ⭐ **Favorites Section**: Add books to your favorites list for easy access later.
- 🎧 **Book Playlist**: Group books into a personalized "playlist."
- 👤 **User Profile**: Create and manage your profile with personal information and reading preferences.
- 🔒 **Authentication**: Login and sign-up pages for user registration.

## Technologies Used:

- **Flutter**: Main framework for the app development.
- **Dart**: Programming language used with Flutter.
- **Firebase**:
  - **Firebase Authentication**: For user login, signup, and session management.
  - **Firebase Realtime Database**: For storing user data like favorites and playlists.
  - **Firebase Storage**: For storing and retrieving book cover images.
- **Google Books API**: To fetch book data such as titles, authors, descriptions, and other metadata.

## Setup Instructions:

### Prerequisites:

- Install Flutter: [Flutter installation guide](https://flutter.dev/docs/get-started/install)
- Set up Firebase project: [Firebase setup guide](https://firebase.google.com/docs/flutter/setup)
- Google Books API key: Obtain a key from [Google Cloud Console](https://console.cloud.google.com/)

## Next Steps:

- Integration with Google Calendar to create reading events.
- Improve UI/UX based on user feedback.
