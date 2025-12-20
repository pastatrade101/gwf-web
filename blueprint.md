# Tanzania Regions App

## Overview

This is a Flutter application that allows users to explore the regions and councils of Tanzania. The app provides a list of all regions in Tanzania, and for each region, it lists the respective councils. Each council has a link to its official website, which can be opened from within the app.

## Features

*   **Onboarding Screen:** A welcoming screen for first-time users.
*   **Home Screen:** Displays a list of all Tanzanian regions.
*   **Search Functionality:** Allows users to search for regions and councils.
*   **Expandable Region Cards:** Each region is displayed as an expandable card, showing the councils within that region when expanded.
*   **Direct link to Council Websites:** Each council has a button that opens its official website.

## Design

*   **Theme:** The app uses a color scheme inspired by the Tanzanian flag, with a dark primary color and white text.
*   **Typography:** The app uses the `google_fonts` package with the `Nunito` font for a clean and modern look.
*   **Layout:** The layout is designed to be simple and intuitive, with a clear hierarchy of information.

## Project Structure

```
lib/
├── app/
│   └── app.dart
├── data/
│   ├── models/
│   │   ├── council.dart
│   │   └── region.dart
│   └── region_data.dart
├── features/
│   └── home/
│       ├── home_screen.dart
│       └── widgets/
│           ├── council_tile.dart
│           ├── header.dart
│           ├── region_card.dart
│           └── search_bar.dart
├── main.dart
├── onboarding_screen.dart
└── services/
    └── url_launcher_service.dart
```
