# 🛡️ HillGuard: Complete Technical Pipeline & Demo Blueprint
### Unified Solution for B1 (Offline Landslide Reporter & Alert Relay) & B6 (Road Status Mesh)

---

## 1. Executive Summary & Problem Solving Matrix

During heavy monsoon downpours (>300 mm rain in 12 hours) in mountainous regions like Darjeeling, Sikkim, and Uttarakhand, cell towers and power grids are wiped out. 

**HillGuard solves the two critical failure points identified by disaster authorities:**
1. **The B1 Gap (Report Up & Relay Down):** Ground walkers notice slope warning signs (tension cracks, seepage, retaining wall bulges), but have no connectivity to report them. Conversely, official meteorological high-risk alerts issued by the IMD/NDMA never reach isolated villagers with zero signal.
2. **The B6 Gap (Road Status Mesh):** Commuters asking *"Is NH-55 open? Is Rohini blocked?"* are blind to fresh mudslides and rockfalls. HillGuard turns everyday mobile phones into a multi-hop mesh network that passes blockage reports car-to-car without internet, and summarizes them into an on-device highway status board.

---

## 2. End-to-End System Pipeline Diagram

```
                 OFFLINE FIELD (0% INTERNET / NO CELL SERVICE)
 ─────────────────────────────────────────────────────────────────────────────
 📱 PHONE A (Field Walker / Commuter)
   │
   ├─► 1. EDGE INPUT: Photo + Geological Features (Cracks, Seepage, Wall Bulge)
   │                  + Real GPS Latitude, Longitude, Altitude
   │
   ├─► 2. ON-DEVICE AI EVALUATOR:
   │      • Calculates Geotechnical Risk Score (0 - 100)
   │      • Plain-Language Engineering Explanation
   │      • Prioritized Life-Safety Action Plan
   │
   ├─► 3. LOCAL PERSISTENCE:
   │      • Saves to On-Device SQLite / SharedPreferences DB (Zero Data Loss)
   │
   ├─► 4. DUAL-CHANNEL P2P MESH DISPATCH:
   │      • Channel 1 (UDP Port 44555): Subnet broadcast to 255.255.255.255 & 192.168.43.255
   │      • Channel 2 (TCP Port 44556): Kernel ARP Table sweep (/proc/net/arp) to connected peers
   │
   ▼
 📶 LOCAL WI-FI HOTSPOT / BLE RADIO WAVES (No SIM, No Recharge, No Internet)
   │
   ▼
 📱 PHONE B (Offline Villager / Relief Camp Node / Passing Vehicle)
   │
   ├─► 5. BACKGROUND MESH ENGINE:
   │      • Ingests packet on TCP 44556 / UDP 44555
   │      • Hashing Deduplication: Discards duplicates, increments hop count (TTL: 5–7)
   │      • Store & Forward Queue: Holds packet to pass to the next vehicle (Data Mule)
   │
   ├─► 6. NATIVE SYSTEM ALERTS:
   │      • Physical Hardware Vibration (`HapticFeedback.heavyImpact()`)
   │      • Android Status Bar Emergency Notification (Fires even if screen is locked)
   │
   ├─► 7. OFFLINE VECTOR GIS CARTOGRAPHY:
   │      • Vector Highways (NH-55, Rohini, NH-10) render on-device without web tiles
   │      • Dynamic Status: Blocked roads turn glowing red; safe corridors stay green
   │      • Isometric Contours & Distance Range Rings (500m, 1.5km, 3km)
   │
   ├─► 8. B6 ROUTE STATUS BOARD:
   │      • On-device engine de-duplicates multi-peer reports & summarizes corridors
   │
 ─────────────────────────────────────────────────────────────────────────────
            CLOUD SYNC (WHEN ANY PHONE REACHES A RECONNECTED HOTSPOT)
 ─────────────────────────────────────────────────────────────────────────────
 📱 ANY CONNECTED MESH PHONE
   │
   └─► 9. SYNC MANAGER:
          • Auto-detects 4G/5G/Satellite link
          • Flushes queued reports via REST API to NestJS + PostgreSQL / PostGIS Cloud
          • Authority Emergency Dashboard updates in real time via WebSockets
```

---

## 3. Detailed Component Pipeline

### Pipeline Stage 1: Edge Observation & Geotechnical Assessment (B1)
- **Input:** Walker spots slope instability, opens HillGuard, snaps photo, checks visual features:
  - *Tension Cracks*, *Groundwater Seepage*, *Retaining Wall Bulge*, *Tilted Trees*, *Fresh Debris*.
- **On-Device Algorithm (`LandslideEvaluator`):**
  - Inputs slope angle (e.g., 52°) + geological indicators.
  - Generates instant risk rating: `LOW (0-30)`, `MEDIUM (31-60)`, `HIGH (61-80)`, or `CRITICAL EVACUATION (81-100)`.
  - Generates plain-language explanation: *"Imminent rotational shear failure. Fissures coupled with hydrostatic pore pressure indicate slope collapse risk."*
  - Generates life-safety action checklist: *"Evacuate downhill perimeter, avoid driving along cut slope, alert emergency committee."*

### Pipeline Stage 2: Peer-to-Peer Offline Transport (B1 & B6)
- **Zero Internet Requirement:** Uses local portable Wi-Fi hotspot or Bluetooth Low Energy.
- **Dual-Channel Socket Architecture (`P2PSocketService`):**
  - **UDP Port 44555:** Instant broadcast beacon for auto-discovery and UDP datagram dispatch.
  - **TCP Port 44556:** Reliable stream transfer. Automatically inspects Linux kernel ARP table (`/proc/net/arp`) on Android to detect peer IPs (e.g., `192.168.43.x`) and executes two-way handshakes.
- **Multi-Hop & Data Mule Routing (`MeshEngine`):**
  - Each packet has a UUID, origin timestamp, TTL counter (5 for crowd reports, 7 for official alerts).
  - Packets are passed phone-to-phone. Moving vehicles act as **Data Mules**, carrying packets from cut-off mountain roads into town centers.

### Pipeline Stage 3: Relay Down — Official Government Warnings (B1)
- When a phone with intermittent connectivity receives an official alert (*e.g., IMD Red Alert: 300mm rain expected*):
  - The user taps **"Relay Alert (B1)"**.
  - HillGuard packages this into a high-priority packet (`priority = 3, maxTtl = 7`).
  - The packet spreads downward across offline phones in the valley.

### Pipeline Stage 4: Background Wakeup & Android Status Bar Notifications
- **Offline WakeLock & Notification Service (`NotificationService`):**
  - Native Android notification channel (`hillguard_emergency_alerts`) configured with `Importance.max` and `Priority.high`.
  - When Phone B receives an alert while minimized or with screen locked:
    - Android triggers a distinctive emergency vibration pattern `[0, 600, 250, 600, 250, 600]`.
    - Android drops down a native Status Bar Notification with full details.

### Pipeline Stage 5: Offline Vector GIS Cartography
- **No Blank Grey Map Screen (`DisasterMapScreen`):**
  - Instead of failing web tiles, the app renders vector mountain highway polylines (**NH-55 Hill Cart Road, Rohini Bypass, NH-10 Teesta Canyon, Pankhabari Road, Teesta River Basin**) directly using on-device coordinates.
  - Roads dynamically turn **Red** when blocked and **Green** when open.
  - Background renders isometric elevation contour curves (`_TacticalTopoBackgroundPainter`) and GPS radar range rings (500m, 1.5km, 3km).
  - Hazard markers feature labeled badges (e.g., `[NH-55] BLOCKED`, `850m • CRITICAL`).

### Pipeline Stage 6: On-Device Route Status Board (B6)
- **Deduplication & Corridor Synthesis (`RouteStatusBoard`):**
  - Eliminates duplicate traveler complaints.
  - Answers the daily question: *"Is NH-55 open? Is Rohini blocked?"*
  - Clearly displays vehicle clearance: **2-Wheelers (Passable/Blocked)** and **4x4 (Passable/Blocked)** with estimated clearance time.

### Pipeline Stage 7: Store-and-Forward Cloud Sync
- **Backend Architecture (`SyncManager` + NestJS + PostGIS):**
  - When any phone connects to internet, pending reports auto-flush to the cloud.
  - Backend stores geographical coordinates using PostGIS spatial geometry (`ST_Point(long, lat)`).

---

## 4. Step-by-Step Live Demo Guide (For Judges / Evaluators)

**Setup Time:** 1 Minute  
**Required:** 2 Android Phones (Phone A & Phone B), Zero Internet.

### Step 1: Prove 0% Internet
- Turn **OFF Mobile Data** on both Phone A and Phone B.
- Phone A turns **ON Portable Hotspot**.
- Phone B turns **ON Wi-Fi** and connects to Phone A's hotspot.

### Step 2: Show Peer Discovery (Mesh HUD)
- Open HillGuard on both phones.
- Tap the **Mesh HUD** tab:
  - Both phones immediately show each other under **Discovered Peer Nodes** with a green **`PHYSICAL`** badge and local IP address (`192.168.43.x`).

### Step 3: Demo B1 "Report Up" (On-Device Risk Classification)
- On Phone A, tap **"Report Landslide (B1)"**.
- Slide slope angle to 52°, select *Tension Cracks* + *Water Seepage*.
- Point out to the judge:
  - Dynamic risk score calculated on-device: **Critical Evacuation (88/100)**.
  - Plain-language explanation generated by geotechnical rules.
  - Life-safety checklist (Evacuate downhill perimeter).
- Tap **Submit**.

### Step 4: Show Instant Offline Delivery & Physical Buzz on Phone B
- **Immediately look at Phone B:**
  - Phone B physically **vibrates** in your hand.
  - Emergency alert banner slides down.
  - If Phone B was minimized, a **native Android status bar notification** appears.
  - Tap **Field Feed**: the report is at the top with a **`RELAYED (1 HOPS)`** badge.

### Step 5: Demo B1 "Relay Down" (Official High-Risk Warning)
- On Phone A, tap the red **"Relay Alert (B1)"** button on the home screen.
- Select **"IMD Red Alert: 300mm Torrential Rain"** and tap **Rebroadcast**.
- Phone B receives the red alert popup instantly across the air with zero cellular service.

### Step 6: Demo B6 "Road Status Mesh & Route Board"
- On Phone A, tap **"Report Road (B6)"**, select **NH-55**, mark **Blocked** by *Rockfall*, set **No 2-Wheelers / No 4x4**. Tap **Broadcast**.
- Open **Route Board (B6)** on Phone B:
  - Show how individual reports are synthesized:  
    `NH-55: 🛑 BLOCKED at Mile 18 | 2-Wheelers: NO | 4x4: NO | Est: 4-6h`  
    `Rohini Road: 🟢 NORMAL (Open All Vehicles)`
- Open **Disaster Map**:
  - Show the **vector NH-55 polyline glowing red** on the offline topographic map with zero internet tiles!

---

## 5. File & Codebase Reference Guide

| Module | Key Files | Function |
|---|---|---|
| **Core Mesh Engine** | `lib/core/mesh/p2p_socket_service.dart`<br>`lib/core/mesh/mesh_engine.dart` | Dual-channel UDP/TCP sockets, Linux ARP table parsing, packet deduplication, multi-hop routing. |
| **B1 Landslide Reporter** | `lib/modules/b1_landslide/landslide_reporter_screen.dart`<br>`lib/core/models/landslide_report.dart` | Geological feature selection, on-device AI risk evaluation, plain-language guidance. |
| **B6 Road Mesh & Board** | `lib/modules/b6_road_mesh/road_reporter_screen.dart`<br>`lib/modules/b6_road_mesh/route_status_board.dart`<br>`lib/core/models/road_report.dart` | Crowd-sourced road blockage reports, on-device corridor summarization board. |
| **System Notifications** | `lib/core/notifications/notification_service.dart` | Native Android `Importance.max` notification channel, full-screen intents, custom vibration patterns. |
| **Offline Vector GIS Map** | `lib/modules/map/disaster_map_screen.dart` | Vector road network (NH-55, Rohini, NH-10), isometric contour canvas painter, radar rings, hazard badges. |
| **Storage & Sync** | `lib/core/storage/local_store.dart`<br>`lib/core/sync/sync_manager.dart` | On-device persistent SQLite/Prefs database, opportunistic cloud sync when internet appears. |
| **Backend Service** | `Backend/src/modules/landslide/`<br>`Backend/src/modules/road-mesh/`<br>`Backend/src/modules/alerts/` | NestJS, TypeORM, PostgreSQL PostGIS spatial queries, WebSocket alert gateways. |

---

## 6. Pre-Built APK Binaries

- **Release APK (Optimized, 58.3 MB):**  
  `Frontend_app/build/app/outputs/flutter-apk/app-release.apk`
- **Debug APK (193 MB):**  
  `Frontend_app/build/app/outputs/flutter-apk/app-debug.apk`
