
# Tanzania Regions & Councils Explorer - Blueprint

## Overview

This document outlines the plan for creating a Flutter application that serves as a directory for all regional and council websites in Tanzania. The app will provide a user-friendly interface to browse, search, and access these websites.

## Features

*   **Region & Council Listing:** Display a comprehensive list of all 26 regions and 184 councils in Tanzania.
*   **Search Functionality:** Allow users to search for specific regions or councils.
*   **Website Navigation:** Enable users to open the official website for each council with a single tap.
*   **Modern UI/UX:** A visually appealing and intuitive design, following Material Design guidelines.
*   **Responsive Design:** The app will be responsive and work well on both mobile phones and web browsers.

## Application Architecture

*   **State Management:** We will use `provider` for managing the app's theme and other shared states.
*   **Navigation:** We will use `go_router` for declarative navigation, which is robust and supports deep linking.
*   **Data:** The region and council data will be stored locally within the app for fast access.
*   **UI Components:** We will use a combination of modern UI components to create a visually appealing and interactive experience. This includes `Card` widgets for list items, `ExpansionTile` for a nested list of councils under regions, and a search bar for filtering.

## Implementation Plan

1.  **Setup Project:**
    *   Add necessary dependencies: `google_fonts`, `provider`, `url_launcher`, and `go_router`.
    *   Create a `blueprint.md` file to document the project.

2.  **Create Data Model:**
    *   Define a data structure for regions and councils in `lib/data.dart`.
    *   Populate the data file with sample data for regions and councils.

3.  **Develop UI:**
    *   **Theme:** Implement a theme with `google_fonts` and a custom color scheme in `lib/main.dart`.
    *   **Home Screen:** Create a home screen (`lib/home_screen.dart`) that displays a searchable list of regions.
    *   **Region Details Screen:** Create a screen (`lib/region_details_screen.dart`) to show the councils of a selected region.

4.  **Implement Functionality:**
    *   **Search:** Add search logic to filter regions and councils.
    *   **Navigation:** Set up routes using `go_router` to navigate between the home screen and region details screen.
    - **Website Launching:** Use the `url_launcher` package to open council websites.

5.  **Refine and Test:**
    *   Ensure the app is responsive and handles errors gracefully.
    *   Format the code and run analysis to ensure code quality.
