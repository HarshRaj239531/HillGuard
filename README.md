<div align="center">

# 🛡️ HillGuard

### Decentralized Offline-First Disaster Intelligence & Road Mesh Network

**Civic Emergency Triage, Geotechnical Slope Safety, and Peer-to-Peer Communication for Mountain Communities**

[![Google Hackathon 2026](https://img.shields.io/badge/Google%20Solution%20Challenge-2026-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://developers.google.com/community/solutions-challenge)
[![Flutter](https://img.shields.io/badge/Flutter-3.11+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![NestJS](https://img.shields.io/badge/NestJS-10.0-E0234E?style=for-the-badge&logo=nestjs&logoColor=white)](https://nestjs.com)
[![PostGIS](https://img.shields.io/badge/PostgreSQL-PostGIS%20Spatial-336791?style=for-the-badge&logo=postgresql&logoColor=white)](https://postgis.net)
[![PWA Ready](https://img.shields.io/badge/PWA-100%25%20Offline%20First-059669?style=for-the-badge&logo=pwa&logoColor=white)](https://harshraj239531.github.io/HillGuard/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

<br/>

**🌐 [Launch Live Web PWA (Runs Offline)](https://harshraj239531.github.io/HillGuard/)** • **📱 [Pre-Built Android APK](#-pre-built-android-binaries)** • **🎬 [1-Minute Live Demo Flow](#-1-minute-live-judge-demo-guide)** • **🏗️ [System Architecture](#-end-to-end-system-architecture)** • **⚙️ [Local Setup](#-installation--local-setup)**

<br/>

---

### 🌐 UN Sustainable Development Goals (SDGs) Addressed

|                               **SDG 3: Good Health & Well-Being**                                |                     **SDG 9: Industry, Innovation & Infrastructure**                      |                           **SDG 11: Sustainable Cities & Communities**                           |                              **SDG 13: Climate Action**                               |
| :----------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------: |
| Emergency medical triage, hypothermia guidance, and instant hospital navigation during cut-offs. | Resilient, decentralized P2P wireless mesh functioning with zero cellular infrastructure. | Disaster risk reduction and decentralized early warning systems for vulnerable hill settlements. | Climate adaptation for extreme monsoon cloudbursts, flash floods, and slope failures. |

---

</div>

<br/>

## 📌 Executive Summary & The Himalayan Challenge

During extreme Himalayan monsoon downpours (>300 mm rainfall in under 12 hours) across high-risk mountain sectors like **Darjeeling, Sikkim, Uttarakhand, and Nepal**, mountain slopes destabilize, triggering catastrophic flash floods and debris torrents. Within minutes:

- **Cell towers collapse** or lose backup generator power.
- **Underground fiber optic conduits snap** along road washaways.
- **Mountain highways (e.g., NH-55, NH-10) are severed**, stranding thousands of travelers, locals, and supply trucks.

> [!CRITICAL]
> **The Tragic Communication Void:** When disaster strikes, modern cloud-dependent apps become useless grey screens saying _"No Internet Connection"_. Victims cannot locate nearby shelters, field walkers cannot warn downslope hamlets, and ambulance drivers cannot tell which mountain pass is open or blocked.

**HillGuard solves this crisis with a 100% offline-first civic emergency mesh ecosystem** that requires **0% cellular data, 0% internet connectivity, and no SIM card**. By leveraging on-device geotechnical AI models, peer-to-peer Wi-Fi/Bluetooth dual-channel sockets, moving vehicular **"Data Mules"**, and vector-drawn offline GIS maps, HillGuard creates an unkillable safety web across the hills.

---

## 🎯 The Three Core Civic Pillars

HillGuard unites three critical emergency response tiers into a single, cohesive platform:

```
                                    ┌─────────────────────────────────────────────────────────────┐
                                    │                   🛡️ HILLGUARD PLATFORM                    │
                                    └──────────────────────────────┬──────────────────────────────┘
                                                                   │
               ┌───────────────────────────────────────────────────┼───────────────────────────────────────────────────┐
               ▼                                                   ▼                                                   ▼
┌──────────────────────────────┐                ┌──────────────────────────────┐                ┌──────────────────────────────┐
│        🔴 AMBITIOUS          │                │       🟠 B1 CHALLENGE        │                │       🟠 B6 CHALLENGE        │
│ Disaster-Ready Hills Helper  │                │  Landslide Report & Relay    │                │    Road Status Mesh Board    │
├──────────────────────────────┤                ├──────────────────────────────┤                ├──────────────────────────────┤
│ • On-Device Medical Triage   │                │ • Geotechnical AI Evaluation │                │ • Moving Car "Data Mules"    │
│ • Offline Safe Haven Finder  │                │ • Slope Stability (0-100)    │                │ • On-Device Corridor Board   │
│ • One-Tap SOS Radio Beacon   │                │ • Peer-to-Peer "Relay Down"  │                │ • Vehicle Clearance Triage   │
│ • Multi-Dialect Localization │                │ • Instant Physical Haptic UI │                │ • Zero-Tile Vector GIS Map   │
└──────────────────────────────┘                └──────────────────────────────┘                └──────────────────────────────┘
```

### 1. 🔴 AMBITIOUS: Disaster-Ready Hills Assistant

- **On-Device Emergency Companion:** A deterministic clinical and survival intelligence engine operating without an internet connection. Provides step-by-step triage for **cloudburst survival, escaping active landslides, hypothermia rewarming, and field tourniquets/splints**.
- **GPS-Calculated Safe Haven Direction:** Automatically determines the distance (in km), elevation, compass bearing (e.g., `NE 42°`), and emergency radio frequencies (VHF/PMR446) of the nearest Primary Health Centre (PHC), Army Base Hospital, or disaster shelter.
- **Multilingual for Himalayan Demographics:** Instant 1-tap switching between **English, Nepali (नेपाली), Hindi (हिन्दी), and Bengali (বাংলা)**.

### 2. 🟠 B1: Landslide Reporter & "Relay Down" Broadcast

- **On-Device Geotechnical Safety Scoring (`LandslideEvaluator`):** Walkers log slope indicators (tension cracks, groundwater seepage, retaining wall bulging, slope angle). The on-device engine instantly computes a geotechnical score (`LOW 0-30`, `MEDIUM 31-60`, `HIGH 61-80`, or `CRITICAL EVACUATION 81-100`) with plain-language engineering explanations.
- **"Relay Down" Disaster Warning:** When an authority warning (e.g., _IMD Red Alert: 300mm Torrential Rain_) reaches a device with fleeting connectivity, users tap **"Relay Alert"** to cascade the warning downwards into disconnected valley hamlets over peer-to-peer radio hops.

### 3. 🟠 B6: Road Status Mesh & Route Board

- **Vehicular "Data Mules":** Passing cars, taxis, and rescue vehicles carry blockage reports hop-by-hop between isolated valley sectors, bridging the network gap without cellular towers.
- **On-Device Route Status Board:** Eliminates duplicate complaints and synthesizes reports into an executive corridor status board:
  - _NH-55: 🛑 BLOCKED at Mile 18 | 2-Wheelers: NO | 4x4: NO | Est: 4-6h_
  - _Rohini Road: 🟢 NORMAL (Open All Vehicles)_
- **Zero-Tile Vector GIS Cartography:** Instead of blank web-tile maps, HillGuard renders vector highways (NH-55 Hill Cart Road, Rohini Bypass, NH-10 Teesta Canyon) directly using on-device geometry with dynamic status colors, topographic contour curves, and GPS radar range rings.

---

## 🏗️ End-to-End System Architecture

```
═════════════════════════════════════════════════════════════════════════════════════════
                   OFFLINE FIELD ENVIRONMENT (0% CELLULAR / NO INTERNET)
═════════════════════════════════════════════════════════════════════════════════════════

 📱 NODE A (Commuter / Field Walker)
   │
   ├─► 1. EDGE SENSING:
   │      • Photo capture + Slope Angle slider + Hazard markers (Cracks, Seepage, Bulge)
   │      • Device GPS Coordinates (Latitude, Longitude, Altitude)
   │
   ├─► 2. ON-DEVICE AI EVALUATOR:
   │      • Deterministic geotechnical risk scoring (0 - 100)
   │      • Plain-language engineering diagnosis & life-safety action checklist
   │
   ├─► 3. LOCAL PERSISTENT STORAGE:
   │      • SQLite & SharedPreferences (Zero data loss, crash-resistant)
   │
   ├─► 4. DUAL-CHANNEL P2P MESH DISPATCH:
   │      • Channel 1 (UDP Port 44555): Subnet broadcast beacon (255.255.255.255)
   │      • Channel 2 (TCP Port 44556): Kernel ARP Table sweep (/proc/net/arp) stream
   │
   ▼
 📶 LOCAL RADIO WAVES / PORTABLE WI-FI / BLE (Zero SIM, Zero Airtime, Zero Recharge)
   │
   ▼
 📱 NODE B (Offline Villager / Passing Vehicle "Data Mule" / Relief Staging Post)
   │
   ├─► 5. BACKGROUND MESH ENGINE:
   │      • Auto-discovery of physical peer nodes
   │      • Hash-based deduplication; packet hop-count increment (TTL: 5-7)
   │      • Store-and-Forward Queue (carries packets across mountain ridges)
   │
   ├─► 6. PHYSICAL ALERT DISPATCH:
   │      • Native Android Status Bar Notification (`Importance.max`, high priority)
   │      • Severe tactile vibration pattern: [0ms, 600ms, 250ms, 600ms, 250ms, 600ms]
   │
   ├─► 7. REAL-TIME VECTOR CARTOGRAPHY:
   │      • Vector Highway polylines (NH-55, Rohini, NH-10) render without tile downloads
   │      • Blocked roads turn glowing red; safe corridors remain green
   │      • Isometric elevation contours & distance radar rings (500m, 1.5km, 3km)
   │
   ├─► 8. CORRIDOR ROUTE SYNTHESIS:
   │      • Synthesizes multi-hop blockage reports into high-level passability clearance
   │
═════════════════════════════════════════════════════════════════════════════════════════
         OPPORTUNISTIC CLOUD SYNC (WHEN ANY PHONE REACHES A RECONNECTED BASE)
═════════════════════════════════════════════════════════════════════════════════════════

 📱 ANY CONNECTED MESH NODE
   │
   └─► 9. AUTOMATIC SYNC MANAGER:
          • Detects 4G/5G/Satellite uplink
          • Flushes queued reports via REST API to NestJS + PostgreSQL PostGIS
          • Disaster Response Teams visualize cluster hotspots via ST_DWithin queries
```

---

## ⚡ Technical Innovation & Engineering Highlights

### 1. Dual-Channel P2P Socket Engine (`P2PSocketService`)

Unlike standard Bluetooth-only prototypes that suffer from extreme range limits (<10m in rain) and low data rates, HillGuard implements a **hybrid dual-channel socket network**:

- **UDP Subnet Broadcast (Port 44555):** Transmits high-frequency discovery datagrams across `255.255.255.255` and `192.168.43.255` for instantaneous peer auto-discovery without pairing.
- **TCP Stream Handshake (Port 44556):** Inspects the Linux kernel ARP table (`/proc/net/arp`) on Android devices to dynamically identify connected peer IP addresses and establish reliable two-way binary streams.

### 2. Zero-Tile Vector GIS Cartography (`DisasterMapScreen`)

Traditional mapping libraries fail in disaster zones because they attempt to download HTTP map tiles, resulting in blank grey screens. HillGuard includes a custom **Canvas Vector Cartography Engine**:

- Renders major mountain arteries (**NH-55 Hill Cart Road, Rohini Bypass, NH-10 Teesta Canyon, Pankhabari Heritage Road, Teesta River Basin**) using pre-compiled geographic coordinate vectors.
- Roads dynamically shift color from **Emerald Green** to **Pulsing Crimson Red** when a blockage report is received over the mesh.
- Renders an isometric contour background (`_TacticalTopoBackgroundPainter`) and tactical radar distance rings (500m, 1.5km, 3km) to provide spatial awareness without internet.

### 3. Background Wakeup & Hardware Haptics

- Configures a dedicated Android high-priority notification channel (`hillguard_emergency_alerts`) with `Importance.max`.
- Ingests emergency alerts even when the device is locked in a backpack or pocket, triggering a distinctive triple-burst vibration pattern (`[0, 600, 250, 600, 250, 600]`) and dropping down a native heads-up emergency notification.

### 4. PostGIS Spatial Intelligence & Cloud Synchronization

- **Backend Architecture:** Built with **NestJS**, **TypeScript**, and **PostgreSQL with PostGIS** spatial extensions.
- When any node reaches connectivity, pending reports are flushed to the cloud.
- Evaluates spatial proximity using `ST_DWithin` and PostGIS spatial GIST indices (`ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography`) to compute real-time hazard clusters across mountain sectors.

---

## 🛠️ Google Technologies & Tech Stack

| Layer                            | Technologies Used                      | Description & Purpose                                                                       |
| -------------------------------- | -------------------------------------- | ------------------------------------------------------------------------------------------- |
| **Mobile & Web Client**          | **Flutter 3.11+ & Dart 3**             | Single cross-platform codebase compiling to native Android and Progressive Web App (PWA).   |
| **User Experience & Typography** | **Google Material 3 & Google Fonts**   | High-contrast, accessibility-first design token system (Outfit & Inter fonts).              |
| **On-Device Geotechnical AI**    | **Dart Deterministic Evaluator**       | Real-time geotechnical slope stability rules and plain-language action generator.           |
| **Cloud AI & LLM**               | **Google Gemini API**                  | Cloud-side synthesis of multi-source incident logs and hazard assessment summarization.     |
| **Spatial Database**             | **PostgreSQL + PostGIS**               | Geographic spatial geometry queries (`ST_DWithin`, `ST_Point`, GIST indexing).              |
| **Backend API & WebSockets**     | **NestJS & Socket.io**                 | Enterprise modular TypeScript backend with real-time incident event distribution.           |
| **PWA & Offline Storage**        | **Service Workers (`sw.js`) + SQLite** | Total offline boot capability, Cache API pre-caching, and zero-data-loss local persistence. |
| **DevOps & Containers**          | **Docker & Docker Compose**            | Multi-container deployment orchestrating NestJS API and PostGIS database services.          |

To demonstrate HillGuard's **0% internet capability** to hackathon judges or evaluators:

> **Prerequisites:** 2 Android phones (Phone A and Phone B) with HillGuard installed, or 1 phone and 1 laptop. **Total setup time: 60 seconds.**

### Step 1: Prove 0% Internet Connectivity

1. Turn **OFF Mobile Data** and **OFF Wi-Fi Internet** on both devices.
2. On Phone A: Turn **ON Portable Hotspot** (no internet connection required).
3. On Phone B: Turn **ON Wi-Fi** and connect to Phone A's hotspot.

### Step 2: Verify Peer Auto-Discovery (Mesh HUD)

1. Open HillGuard on both devices.
2. Tap the **Mesh HUD** tab:
   - Both devices immediately detect each other under **Discovered Peer Nodes** with a green **`PHYSICAL`** badge and local IP address (`192.168.43.x`).

### Step 3: Trigger B1 "Report Up" (On-Device Geotechnical Evaluation)

1. On Phone A: Tap **"Report Landslide (B1)"**.
2. Slide the slope angle to **52°**, select **Tension Cracks** and **Water Seepage**.
3. Point out to the judges:
   - **Risk Score:** Instant calculation of **Critical Evacuation (88/100)** without any network request.
   - **Plain-Language Engineering Diagnosis:** _"Imminent rotational shear failure. Fissures coupled with hydrostatic pore pressure indicate slope collapse risk."_
   - **Action Checklist:** _"Evacuate downhill perimeter immediately."_
4. Tap **Submit & Broadcast to Mesh**.

### Step 4: Verify Instant P2P Buzz on Phone B

1. Look at Phone B immediately:
   - Phone B **physically vibrates** in hand with emergency haptics.
   - An emergency banner slides down displaying the critical warning.
   - Under the **Incident Feed**, the report appears marked with **`RELAYED (1 HOP)`**.

### Step 5: Test B1 "Relay Down" (Official High-Risk Warning)

1. On Phone A: Tap the red **"Relay Alert (B1)"** button on the home screen.
2. Select **"IMD Red Alert: 300mm Torrential Rain"** and tap **Rebroadcast**.
3. Phone B receives the red alert popup over the air with zero cellular reception.

### Step 6: Test B6 "Road Status Mesh & Route Board"

1. On Phone A: Tap **"Report Road (B6)"**, select **NH-55**, mark **Blocked** by _Rockfall_, and set **No 2-Wheelers / No 4x4**. Tap **Broadcast**.
2. Open **Route Board (B6)** on Phone B:
   - Notice how individual reports are synthesized into a corridor overview:  
     `NH-55: 🛑 BLOCKED at Mile 18 | 2-Wheelers: NO | 4x4: NO | Est: 4-6h`  
     `Rohini Road: 🟢 NORMAL (Open All Vehicles)`
3. Open the **Disaster Map**:
   - The **vector NH-55 polyline turns glowing red** on the offline topographic map with zero internet tiles!

---

## 🌐 Public Live PWA & Offline Verification

### 🔗 Public URL: [https://harshraj239531.github.io/HillGuard/](https://harshraj239531.github.io/HillGuard/)

### How to Test 100% Offline in Browser:

1. **First Load:** Open the URL on a mobile device or desktop browser (Chrome/Safari). The custom Service Worker (`sw.js`) pre-caches the Flutter engine, WebAssembly runtime, emergency knowledge base, and safe haven directory.
2. **Install to Home Screen:** Tap **"Add HillGuard to Home Screen"** to install as a standalone PWA.
3. **Turn ON Airplane Mode:** Disconnect Wi-Fi and Mobile Data completely.
4. **Reopen the App:** HillGuard boots instantly from cache with 100% offline functionality across all core modules!

---

## 📱 Pre-Built Android Binaries

Pre-compiled Android APKs are ready for direct installation:

- **Release APK (Optimized):**  
  [`Frontend_app/build/app/outputs/flutter-apk/app-release.apk`](file:///d:/HillGuard/Frontend_app/build/app/outputs/flutter-apk/app-release.apk)
- **Debug APK:**  
  [`Frontend_app/build/app/outputs/flutter-apk/app-debug.apk`](file:///d:/HillGuard/Frontend_app/build/app/outputs/flutter-apk/app-debug.apk)

---

## 📁 Repository Structure

```
HillGuard/
├── .github/
│   └── workflows/
│       └── deploy-pwa.yml          # Automated Flutter Web PWA deploy to GitHub Pages
├── Backend/                        # NestJS + PostGIS Spatial Microservice
│   ├── src/
│   │   ├── database/               # PostgreSQL Connection Pool & PostGIS queries
│   │   ├── modules/
│   │   │   ├── alerts/             # Emergency Alert Broadcast Gateway
│   │   │   ├── landslide/          # B1 Landslide Report Ingestion & Spatial Clusters
│   │   │   ├── mesh/               # Mesh Packet Ingestion & Relay Routing
│   │   │   ├── road/               # B6 Road Condition Mesh API (ST_DWithin queries)
│   │   │   └── safe-haven/         # Safe Haven & PHC Spatial Directory
│   │   ├── app.module.ts
│   │   └── main.ts                 # Bootstrap server on port 3000
│   ├── docker-compose.yml          # Multi-container setup: PostGIS 16 + NestJS API
│   ├── Dockerfile
│   ├── init-postgis.sql            # PostGIS schema, spatial GIST indexes & seed data
│   └── package.json
├── Frontend_app/                   # Cross-Platform Flutter Client (Android / Web PWA)
│   ├── lib/
│   │   ├── core/
│   │   │   ├── assistant/          # Offline Triage Rulebase & Knowledge Base
│   │   │   ├── localization/       # Multilingual Engine (EN, NE, HI, BN)
│   │   │   ├── location/           # Geolocation & Distance Calculation Service
│   │   │   ├── mesh/               # Dual-Channel P2P Sockets (UDP 44555 / TCP 44556)
│   │   │   ├── models/             # Landslide, Road Report, and Mesh Packet Models
│   │   │   ├── notifications/      # Android Status Bar High-Importance Alerts
│   │   │   ├── storage/            # LocalStore (SQLite / SharedPreferences)
│   │   │   ├── sync/               # Opportunistic Cloud Sync Manager
│   │   │   └── theme/              # Tactical Disaster Design Tokens & Colors
│   │   ├── modules/
│   │   │   ├── assistant/          # Hills Assistant Chat & Safe Haven Navigation
│   │   │   ├── b1_landslide/       # B1 Slope Evaluation & Landslide Reporter Screen
│   │   │   ├── b6_road_mesh/       # B6 Road Reporter & Route Status Board
│   │   │   ├── home/               # Dashboard, Feed, SOS Beacon, and Relay Controls
│   │   │   ├── map/                # Offline Vector GIS Map & Topo Contour Canvas
│   │   │   └── mesh_hud/           # Real-Time Mesh Radar HUD & Peer Diagnostics
│   │   └── main.dart               # MultiProvider bootstrap & app lifecycle
│   ├── web/
│   │   ├── index.html
│   │   ├── manifest.json           # Standalone PWA Manifest configuration
│   │   └── sw.js                   # Offline Service Worker pre-caching engine
│   └── pubspec.yaml                # Flutter dependencies & metadata
├── PROJECT_PIPELINE.md             # Complete Technical Pipeline & Demo Blueprint
└── README.md                       # Master Hackathon Documentation
```

---

## ⚙️ Installation & Local Setup

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.11+ recommended)
- [Node.js](https://nodejs.org/) (v18+ or v20+)
- [Docker & Docker Compose](https://www.docker.com/) (Optional, for PostGIS backend)

---

### 1. Running the Flutter Mobile App & Web PWA

```bash
# Clone the repository
git clone https://github.com/HarshRaj239531/HillGuard.git
cd HillGuard/Frontend_app

# Install Flutter dependencies
flutter pub get

# Run on a connected Android device or emulator
flutter run

# Or launch as an offline Web PWA in Chrome
flutter run -d chrome
```

To compile an optimized Android release APK:

```bash
flutter build apk --release
```

---

### 2. Running the Backend with PostGIS (Docker Compose)

The easiest way to run the backend and spatial database is via Docker Compose:

```bash
cd HillGuard/Backend

# Start PostgreSQL with PostGIS and the NestJS API
docker-compose up --build
```

The database initializes automatically with `init-postgis.sql`, enabling spatial extensions, table schemas, GIST indices, and sample mountain road seed data.

#### Verifying Backend Endpoints:

- **API Health & Endpoints:** `http://localhost:3000/api`
- **Landslide Reports API:** `http://localhost:3000/api/reports/landslide`
- **Road Condition Mesh API:** `http://localhost:3000/api/reports/road`
- **Nearby Spatial Query (PostGIS `ST_DWithin`):** `http://localhost:3000/api/reports/road/nearby?lat=26.8820&lon=88.2780&radiusMeters=5000`
- **Mesh Ingest Gateway:** `http://localhost:3000/api/mesh/ingest`

---

## 🗺️ Future Roadmap & Scalability

- [ ] **LoRa (Long Range) / ESP32 Bridge:** Connect low-cost sub-GHz LoRa transceiver modules (433MHz / 868MHz) via USB-OTG or BLE for long-range 15 km mountain valley mesh hops.
- [ ] **On-Device Gemini Nano Integration:** Deploy Google's lightweight Gemini Nano model on supported Android devices for multimodal camera-based landslide crack analysis directly on the edge.
- [ ] **Android 15 Direct-to-Satellite Emergency Messaging:** Integrate Android satellite messaging APIs to broadcast high-priority SOS packets when all local mesh peers are unreachable.
- [ ] **Drone Relay Gateway ("Air Mule"):** Lightweight autonomous UAVs patrolling severed mountain roads to act as flying mesh relays between disconnected valleys.

---

## 👥 Contributors & Acknowledgements

Developed with ❤️ for mountain communities facing extreme climate risks and built for the **Google Solution Challenge / Hackathon 2026**.

- **Author & Developer:** Harsh Raj ([@HarshRaj239531](https://github.com/HarshRaj239531))
- **Repository:** [https://github.com/HarshRaj239531/HillGuard](https://github.com/HarshRaj239531/HillGuard)
- **Live PWA:** [https://harshraj239531.github.io/HillGuard/](https://harshraj239531.github.io/HillGuard/)

---

<div align="center">
  <sub>Built to keep mountain communities safe, informed, and connected — even when the world goes offline. 🛡️</sub>
</div>
