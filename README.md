# The Warmth

A community alert application for iOS that connects people in need with local volunteers. The Warmth enables community members to report vulnerable individuals—particularly elderly people facing homelessness—and coordinate immediate, dignified assistance for necessities such as food, water, blankets, and medical care.

## Overview

The Warmth is designed to turn compassion into coordinated action. When someone spots a person in need, they can create an alert with location, urgency, and required supplies. Nearby helpers receive notifications and can respond to provide assistance.

The application is currently in active development. Core navigation, data models, and UI foundations are in place; backend integration and map functionality are planned for upcoming releases.

## Features

| Feature | Status | Description |
|---------|--------|-------------|
| Onboarding landing page | Available | Animated hero screen with community statistics and entry into the main app |
| Active cases list | Available | Scrollable feed of reported cases with urgency, needs, and helper status |
| Case data model | Available | Structured model for location, urgency, needs, status, and reporter metadata |
| Tab-based navigation | Available | Map, Cases, Profile, and Report tabs with iOS tab bar minimization |
| Liquid Glass UI components | Available | Reusable `GlassButton` and `GlassCard` components |
| Interactive map | Planned | Real-time case markers with clustering on a map view |
| Report a case | Planned | Form to submit new alerts with location, photos, and needs |
| Push notifications | Planned | Alert nearby volunteers when new cases are reported |
| CloudKit sync | Planned | Cloud-backed persistence and cross-device synchronization |
| User profile and impact tracking | Planned | Volunteer statistics and account management |

## How It Works

```
Reporter                    The Warmth                      Volunteer
   |                            |                               |
   |-- Spot person in need ---->|                               |
   |-- Create alert ------------>|                               |
   |   (location, needs,         |                               |
   |    urgency)                |                               |
   |                            |-- Notify nearby helpers ----->|
   |                            |                               |
   |                            |<-- Volunteer responds --------|
   |                            |                               |
   |                            |-- Track case status --------->|
   |                            |   (Open → In Progress →       |
   |                            |    Resolved → Verified)         |
```

## Case Model

Each alert case includes the following attributes:

| Field | Type | Description |
|-------|------|-------------|
| `personName` | `String?` | Optional identifier for the person in need |
| `location` | `LocationData` | Latitude, longitude, and human-readable address |
| `needs` | `[Need]` | One or more categories of required assistance |
| `urgency` | `Urgency` | Priority level: Critical, High, Moderate, or Low |
| `description` | `String` | Free-text details about the situation |
| `reportedBy` | `String` | Name of the community member who filed the report |
| `reportedAt` | `Date` | Timestamp of when the case was created |
| `status` | `CaseStatus` | Lifecycle state: Open, In Progress, Resolved, or Verified |
| `helpersAssigned` | `Int` | Number of volunteers currently assisting |

### Need Categories

| Category | SF Symbol |
|----------|-----------|
| Food | `fork.knife` |
| Water | `drop.fill` |
| Blanket | `bed.double.fill` |
| Clothing | `tshirt.fill` |
| Medical | `cross.case.fill` |
| Shelter | `house.fill` |
| Hygiene | `shower.fill` |
| Other | `ellipsis.circle.fill` |

## Requirements

| Requirement | Version |
|-------------|---------|
| Xcode | 26.0 or later |
| iOS Deployment Target | 26.0 |
| Swift | 5.0 |
| Supported Devices | iPhone, iPad |

## Project Structure

```
theWarmth/
├── theWarmthApp.swift              # Application entry point
├── Models/
│   └── AlertCase.swift             # Case model, Need enum, mock data
├── Views/
│   ├── MainTabView.swift           # Tab navigation and screen placeholders
│   ├── Onboarding/
│   │   └── LandingView.swift       # Landing page with hero and CTA
│   └── Components/
│       ├── GlassButton.swift       # Reusable glass-style button
│       └── GlassCard.swift         # Reusable glass-style card
├── Assets.xcassets/                # App icon and accent color
├── Info.plist                      # Background modes (remote notifications)
└── theWarmth.entitlements          # CloudKit and push notification entitlements
```

## Getting Started

### Clone the repository

```bash
git clone https://github.com/betallsoph/the-warmth.git
cd the-warmth
```

### Open in Xcode

```bash
open theWarmth.xcodeproj
```

### Build and run

1. Select a simulator or connected device in Xcode.
2. Press `Cmd + R` to build and run.
3. The app launches on the landing page. Tap **Start Helping Now** to enter the main tab interface.

### Configuration

| Setting | Value |
|---------|-------|
| Bundle Identifier | `com.antt.theWarmth` |
| Marketing Version | 1.0 |
| Build Version | 1 |
| Code Signing | Automatic |

Push notifications and CloudKit require a valid Apple Developer account and provisioning profile. Entitlements are preconfigured in `theWarmth.entitlements`.

## Architecture

| Layer | Technology |
|-------|------------|
| UI Framework | SwiftUI |
| Data Persistence | SwiftData (template scaffold; not yet active) |
| Location | CoreLocation (model integration) |
| Cloud Services | CloudKit (entitlements configured) |
| Notifications | APNs via `remote-notification` background mode |
| Concurrency | Swift strict concurrency with `@MainActor` default isolation |

The app entry point loads `LandingView`, which transitions to `MainTabView` on user action. Case data is currently served from static mock data defined in `AlertCase.mockCases`, centered on Ho Chi Minh City locations for development and preview purposes.

## Roadmap

- [ ] MapKit integration with real-time case markers and clustering
- [ ] Case reporting form with location picker and photo attachment
- [ ] Backend API for case persistence and volunteer matching
- [ ] Push notification delivery for new and updated cases
- [ ] CloudKit or server-side sync for cross-device data
- [ ] User authentication and volunteer profile management
- [ ] Case status workflow with verification flow
- [ ] Localization support

## License

This project does not currently specify a license. All rights reserved.

## Author

An T. Tran ([@betallsoph](https://github.com/betallsoph))
