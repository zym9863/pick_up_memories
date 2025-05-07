# pick_up_memories

A Flutter app for recording and revisiting precious memories.

## Project Overview

pick_up_memories aims to help users record important moments in life with images and text, and review beautiful memories through timeline and detail pages. The project adopts a modular design for easy maintenance and expansion.

## Main Features
- Add, edit, and delete memories (supporting images and text)
- Browse all memories by timeline
- View memory details
- Local persistent data storage

## Directory Structure
```
lib/
├── main.dart                // App entry point
├── models/                  // Data models
│   └── memory_item.dart     // Memory data structure definition
├── screens/                 // Feature pages
│   ├── home_screen.dart         // Home page, displays memory list
│   ├── memory_detail_screen.dart // Memory detail page
│   ├── memory_form_screen.dart   // Add/Edit memory page
│   └── timeline_screen.dart      // Timeline view
└── services/                // Business logic and data services
    └── memory_database.dart // Local database operations
```

### Directory Description
- **models/**: Defines the app's data structures for better data management and type checking.
- **screens/**: Contains all UI pages and interaction logic, following componentization for maintainability and reusability.
- **services/**: Encapsulates local database interaction logic for persistent data storage.

## Key Dependencies
- sqflite, sqflite_common_ffi: Local database storage
- path_provider, path: File path management
- provider: State management
- image_picker: Image selection
- flutter_staggered_grid_view: Masonry layout
- table_calendar: Calendar component

## Getting Started
1. Install dependencies:
   ```
   flutter pub get
   ```
2. Run the project:
   ```
   flutter run
   ```

## Others
- The code follows modular and highly maintainable design principles.
- Suggestions and contributions are welcome.