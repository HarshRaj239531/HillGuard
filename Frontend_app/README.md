<div align="center">

# 🛡️ HillGuard - Flutter Mobile & Web Client
### 100% Offline-First Disaster Companion, Peer-to-Peer Mesh Engine & Vector GIS

[![Flutter](https://img.shields.io/badge/Flutter-3.11+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![PWA Ready](https://img.shields.io/badge/PWA-Offline%20First-059669?style=for-the-badge&logo=pwa&logoColor=white)](https://harshraj239531.github.io/HillGuard/)
[![Google Hackathon 2026](https://img.shields.io/badge/Google%20Solution%20Challenge-2026-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://developers.google.com/community/solutions-challenge)

<br/>

**👉 [View Main Project README & Architecture Guide](../README.md)** • **🌐 [Launch Live Web PWA](https://harshraj239531.github.io/HillGuard/)**

</div>

<br/>

---

## 📱 About the Frontend Application

The `Frontend_app` is a cross-platform client built with **Google Flutter & Dart** targeting both native **Android** devices and modern **Web Progressive Web Apps (PWA)**. 

It is engineered for extreme disaster resilience in mountainous terrains, capable of booting and operating with **0% cellular signal, 0% Wi-Fi internet, and zero SIM card requirement**.

---

## 🚀 Core Features

- **🔴 AMBITIOUS (Disaster-Ready Hills Assistant):**
  - Instant on-device medical & survival triage for cloudbursts, landslide entrapment, cold exposure/hypothermia, and traumatic bleeding.
  - GPS-calculated distance, compass bearing, and elevation to the nearest Primary Health Centre (PHC), Sub-Divisional Hospital, or safe shelter without internet.
  - Emergency SOS Beacon broadcasting distress pulses across local radio waves.
  - Multilingual localization: **English, Nepali (नेपाली), Hindi (हिन्दी), and Bengali (বাংলা)**.

- **🟠 B1 (Landslide Reporter & Alert Relay):**
  - On-device geotechnical slope evaluation: inputs slope angle (e.g., 52°) and visual warning signs (tension cracks, seepage, wall bulges).
  - Calculates instant geotechnical hazard rating (`LOW`, `MEDIUM`, `HIGH`, `CRITICAL EVACUATION 81-100`).
  - "Relay Down" capability: Rebroadcasts high-priority official disaster alerts down to offline valley hamlets peer-to-peer.

- **🟠 B6 (Road Status Mesh & Route Board):**
  - Passing vehicles act as physical "Data Mules", carrying blockage packets hop-by-hop between isolated valley sectors.
  - On-device Route Status Board synthesizes reports, displaying clearance for 2-wheelers and 4x4 vehicles with estimated clearance times.
  - **Zero-Tile Vector GIS Map:** Dynamic custom vector highway polylines (NH-55, Rohini, NH-10) with elevation contour curves and radar range rings that never display blank grey screens.

- **⚡ Dual-Channel P2P Mesh Engine:**
  - UDP Port 44555 subnet broadcast beacon for instant node discovery.
  - TCP Port 44556 Linux kernel ARP table (`/proc/net/arp`) sweep for reliable data streams.
  - Automatic packet deduplication and TTL hop-counter management.
  - Native Android Status Bar High-Priority Emergency Notifications (`Importance.max`) with tactile hardware haptic vibration patterns.

---

## 🛠️ Tech Stack & Dependencies

- **Framework:** Flutter 3.11+ / Dart 3.0+
- **State Management:** Provider (`MultiProvider`, `ChangeNotifier`)
- **Offline Persistence:** SQLite (`sqflite_common_ffi`) & `shared_preferences`
- **Networking:** Native `dart:io` RawDatagramSocket (UDP 44555) & ServerSocket/Socket (TCP 44556)
- **Mapping:** FlutterMap & LatLong2 with custom canvas vector painters
- **Notifications & Haptics:** `flutter_local_notifications` & native `HapticFeedback`
- **Location & Sensors:** `geolocator`
- **Typography & Theme:** `google_fonts` (Outfit, Inter) with tactical disaster color palette

---

## 🏃 Getting Started Locally

### 1. Install Dependencies
```bash
cd Frontend_app
flutter pub get
```

### 2. Run on Android Device / Emulator
```bash
flutter run
```

### 3. Run as Web PWA in Google Chrome
```bash
flutter run -d chrome
```

### 4. Build Optimized Android Release APK
```bash
flutter build apk --release
```
The resulting binary is saved to:  
`Frontend_app/build/app/outputs/flutter-apk/app-release.apk`

---

## 📦 Pre-Built Binaries

- **Release APK:** `build/app/outputs/flutter-apk/app-release.apk`
- **Debug APK:** `build/app/outputs/flutter-apk/app-debug.apk`

---

## 🌐 Live Web PWA Deployment

The Flutter Web client is automatically deployed via GitHub Actions to:  
👉 **[https://harshraj239531.github.io/HillGuard/](https://harshraj239531.github.io/HillGuard/)**

For full architectural blueprints, judge demo guides, and backend setup instructions, refer to the [Root README](../README.md).
