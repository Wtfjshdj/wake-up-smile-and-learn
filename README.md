# Wake Up Smile and Learn

## Overview
"Wake Up Smile and Learn" is a children's app designed to create an engaging and interactive experience for young learners. The app allows users to configure their preferences, ensuring a personalized experience tailored to each child's needs.

## Features
- User-friendly configuration screen for setting up child profiles.
- Form fields for child's name, age group, gender, English level, interests, and alarm sound preferences.
- Smooth animations to enhance visual appeal.
- Local storage for saving user preferences using SharedPreferences.
- Input validation to ensure all required fields are filled out correctly.

## Project Structure
```
wake_up_smile_and_learn
├── lib
│   ├── main.dart
│   ├── screens
│   │   └── configuration_screen.dart
│   ├── widgets
│   │   ├── preference_form.dart
│   │   └── animated_background.dart
│   ├── models
│   │   └── user_preferences.dart
│   ├── services
│   │   └── local_storage_service.dart
│   └── utils
│       └── validators.dart
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

## Setup Instructions
1. Clone the repository:
   ```
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```
   cd wake_up_smile_and_learn
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run the app:
   ```
   flutter run
   ```

## Usage
Upon launching the app, users will be greeted with a configuration screen where they can input their child's details. The app will validate the inputs and save the preferences locally for future use.

## Contributing
Contributions are welcome! Please feel free to submit a pull request or open an issue for any suggestions or improvements.

## License
This project is licensed under the MIT License. See the LICENSE file for details.