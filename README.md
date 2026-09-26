# Glance

![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-3-00A6A6)
![ESP32-S3](https://img.shields.io/badge/hardware-ESP32--S3-E7352C?logo=espressif&logoColor=white)
![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20Web-3DDC84?logo=android&logoColor=white)

A custom digital dashboard (HMI) for a **Yamaha Ray ZR 125 Fi Hybrid** scooter, built with Flutter.

Glance reads speed, odometer, fuel, Eco, Stop & Start and the tell-tales straight from the bike's own wires through a small ESP32-S3 box, the **Bike Interface Module (BIM)**. It shows them on an Android tablet next to Google Maps navigation, and it is designed so the rider understands the whole screen in one glance.

This is a personal, non-commercial project built for one scooter and one rider. It is shared for anyone curious about Flutter on embedded dashboards.

> **Safety.** Glance is experimental. It only **reads** bike signals and never cuts, disables or overrides any engine, brake, lighting or ignition function. Keep the original meter connected and working. It is not certified for road use. Use it at your own risk and check local rules on screens on motorcycles.

## Contents

- [Status](#status)
- [Features](#features)
- [Architecture](#architecture)
- [Tech stack](#tech-stack)
- [Repository layout](#repository-layout)
- [Specification](#specification)
- [Installation](#installation)
- [Testing](#testing)
- [Hardware](#hardware)
- [Roadmap](#roadmap)

## Status

| Phase | What | State |
|---|---|---|
| 1 | Glance HMI and Glance Studio in the browser, on simulated telemetry | Done |
| 2 | Android tablet: kiosk mode, auto launch, auto brightness, heat guard, GPS, Google Maps | Code done, on-device testing next |
| 3 | Signal discovery on the bike, then the BIM on the bench | Waiting for hardware |
| 4 | Piggyback install on the bike next to the original meter, calibration | Planned |
| 5 | Final installation: housing, visor, waterproof connectors | Planned |

Stretch goal: embedded Linux (Raspberry Pi 5 or RK3566 with flutter-pi). Version 2: GPS and 4G tracker, backend, companion app.

## Features

- **Speed as the hero.** One large numeral inside a speed gauge, always from the bike's wheel pulses, never from GPS.
- **Fuel, odometer and trips** read from the bike. Fuel range is learned from real riding.
- **Eco and Stop & Start**, mirrored from the bike's own lamps, including "Auto stop" when the engine stops at a light.
- **Tell-tales:** left and right indicators, high beam, engine (FI) warning, side stand.
- **Google Maps navigation** with place search, two-wheeler routes, turn-by-turn guidance, automatic rerouting and automatic end on arrival.
- **Critical alerts** (low fuel, engine warning, no bike signal) cover everything else.
- **Rider aids:** speed alert, bike battery low warning, service reminder, trip summary at ignition off.
- **Day and night themes**, switched by the ambient light sensor, with automatic brightness.
- **Tablet as a dedicated device:** kiosk mode, starts on boot, heat guard.
- **Glance Studio:** the real HMI in the browser next to a control panel for every signal and fault, so the whole dashboard runs and is tested without any hardware.

## Architecture

Glance has three parts:

| Part | What it does | Link to the next part |
|---|---|---|
| Motorcycle | Speed sensor, fuel sender, Eco and Stop & Start lamps, indicators, high beam, FI lamp, side stand, ignition, 12 V | Read-only, optically isolated taps |
| Bike Interface Module (ESP32-S3) | Hardware pulse counting, fuel ADC, lamp inputs, odometer in flash | USB-C serial, 20 Hz timestamped frames |
| Glance HMI (Flutter) | Draws the dashboard on an Android tablet, in the browser or on desktop | |

**The BIM does the timing, Flutter only draws.** The ESP32-S3 counts wheel pulses in its hardware counter (PCNT), filters fuel, debounces lamps and keeps the odometer. It sends one frame 20 times a second. Flutter never does timing-critical work, which is how the numbers stay accurate.

**Every source speaks the same protocol.** The HMI reads telemetry through one `TelemetrySource` interface. Each source produces real protocol frames and goes through the same parser, CRC and sequence checks:

| Source | Used for |
|---|---|
| `SimulatorSource` | Browser, desktop and tablet without a bike. Driven by hand from Glance Studio |
| `WebSocketSource` | The fake BIM CLI on a laptop, over localhost or Wi-Fi |
| Serial sources (Phase 3) | USB OTG on Android, Web Serial in Chrome, serial ports on desktop and Linux |

### Package layering

| Package | Role | Depends on |
|---|---|---|
| `apps/hmi` | Composition root: picks the telemetry source, the map and the platform services | all packages below |
| `glance_telemetry` | Sources, hub, freshness rules, simulator (pure Dart) | `glance_protocol` |
| `glance_protocol` | Frames, parser, CRC, models (pure Dart) | nothing |
| `glance_maps` | Google map, drawn map, Places and Routes client | nothing from Glance |
| `night_road` | Design tokens and shared widgets | nothing from Glance |
| `tools/fake_bim` | CLI that streams real frames | `glance_protocol`, `glance_telemetry` |

- `glance_protocol` and `glance_telemetry` are pure Dart and never import Flutter, so the fake BIM CLI and the app share one parser and one simulator.
- `night_road` imports no other Glance package; `glance_maps` knows nothing about telemetry.
- `apps/hmi` is the only place that chooses a telemetry source, a map implementation or a platform service.
- Widgets never subscribe to a source. They read telemetry through Riverpod providers and select only the fields they draw, so a telemetry tick never rebuilds the whole tree.
- Every telemetry field carries its own timestamp. Staleness is decided in `glance_telemetry`, never in a widget.
- Platform code (serial, maps, kiosk, storage) lives behind interfaces. No widget branches on the platform.
- Glance Studio wraps the real HMI. The HMI never imports Studio code.

## Tech stack

| Area | Choice |
|---|---|
| App | Flutter 3.47.2, Dart 3.13.2, a Dart pub workspace with one lockfile |
| Targets | Android tablet (main), web (Glance Studio), Windows and Linux desktop |
| State | `flutter_riverpod` 3, providers written by hand, no code generation |
| Storage | `hive_ce` with hand-written JSON (IndexedDB on web) |
| Maps | `google_maps_flutter` with a custom dark style; a drawn schematic map when no key is set |
| Places and routes | Places API (New) text search and Routes API (`TWO_WHEELER`, falling back to `DRIVE`) over `http` |
| Vehicle profile | YAML read with `yaml` |
| Android | Kotlin: device owner kiosk, boot receiver, light sensor, thermal status, location, brightness |
| Firmware (Phase 3) | C++ with PlatformIO, Arduino framework on ESP-IDF, FreeRTOS, on an ESP32-S3 |
| Protocol | Written by hand in Dart and C++, kept in sync by shared byte-level test vectors |
| Testing | `flutter_test`, `test`, golden tests, `integration_test` for frame times |

## Repository layout

```
glance/
    pubspec.yaml                  workspace root, one pubspec.lock
    apps/hmi/                     Glance HMI and Glance Studio (Android, web, Windows, Linux)
    apps/hmi/assets/vehicles/     vehicle profiles (ray_zr_125.yaml)
    packages/glance_protocol/     frames, parser, CRC, models
    packages/glance_telemetry/    TelemetrySource, hub, freshness rules, simulator, WebSocket source
    packages/glance_maps/         map views, route geometry, Places and Routes client
    packages/night_road/          design tokens and shared widgets
    tools/fake_bim/               Dart CLI that streams real frames over WebSocket
    tools/protocol/vectors.json   byte-exact frames checked by the Dart and firmware tests
```

Coming in Phase 3: `packages/glance_serial/`, `firmware/bim/`, `hardware/`, `tools/ride_recorder/`.

## Specification

### Signals read from the bike

Every wire is identified and measured with an auto electrician before anything is connected. Values not yet measured stay `null` in the vehicle profile, and the HMI hides whatever depends on them.

| Signal | How it is read | Notes |
|---|---|---|
| Speed | Wheel pulses through an optocoupler into the ESP32 hardware pulse counter | `speed_kmh = pulses_per_second / pulses_per_rev × wheel_circumference_m × 3.6`. Time between pulses at low speed, pulses per window at high speed. Short moving average, at most 150 ms delay |
| Odometer, Trip A, Trip B | Counted from the same pulses, never GPS | Stored in ESP32 flash (NVS) every 100 m and at ignition off. The original odometer value is entered once |
| Fuel | Fuel sender voltage through a high-impedance op-amp buffer into the ADC | The original meter stays connected because it powers the sender. Median over 10 s, then 60 s smoothing against slosh. Five-point calibration: empty, ¼, ½, ¾, full |
| Eco | Eco lamp through an optocoupler | 100 ms debounce |
| Stop & Start | Stop & Start lamp through an optocoupler | States: off, enabled, engine auto stopped (blink pattern), unknown |
| Indicators, high beam, FI lamp, side stand | Lamp wires through optocouplers | Indicators follow the real signal and are never animated on a timer |
| Ignition | Optocoupler | Required. Drives the trip summary and power behaviour |
| Bike voltage | Divider into the ADC | Feeds the battery low warning |

### BIM to HMI protocol (v1)

USB CDC serial, little endian. The same frames travel over WebSocket from the fake BIM, so every source is tested with the real parser.

| Field | Bytes | Notes |
|---|---|---|
| Sync | 2 | `0xAA 0x55` |
| Version | 1 | Protocol version |
| Type | 1 | Message type, tables below |
| Sequence | 2 | Rises by one per frame |
| Time | 4 | Milliseconds since the BIM booted |
| Length | 2 | Payload length |
| Payload | varies | Per message type |
| CRC | 2 | CRC16-CCITT |

**BIM to HMI**

| Type | Name | Rate | Payload |
|---|---|---|---|
| `0x01` | Telemetry | 20 Hz | speed km/h ×10 (u16), odometer m (u32), Trip A m (u32), Trip B m (u32), fuel % ×10 (u16), fuel raw mV (u16), flags (u16) |
| `0x02` | Status | 1 Hz | bike mV (u16), firmware version (u32), signal health (u8) |
| `0x03` | Event | on change | event code (u8), value (u16) |
| `0x7F` | Ack / error | as needed | code (u8) |

Flags: bit 0 ignition, 1 Eco, 2 Stop & Start enabled, 3 engine auto stopped, 4 left, 5 right, 6 high beam, 7 FI warning, 8 side stand, 9 low fuel, 10 speed signal ok, 11 fuel signal ok.

**HMI to BIM**

| Type | Name | Payload |
|---|---|---|
| `0x10` | Set odometer | odometer m (u32) |
| `0x11` | Reset trip | trip id (u8) |
| `0x12` | Set wheel calibration | factor ×10000 (u32) |
| `0x13` | Save fuel point | percent (u8) |
| `0x14` | Request raw signals | on / off (u8) |
| `0x15` | Ping | none |

`tools/protocol/vectors.json` holds byte-exact frames that both the Dart and the C++ tests decode and encode, so the two sides can never drift apart.

### Data accuracy and freshness

- **No frozen numbers.** With no valid telemetry for 500 ms, the speed digits disappear, a red "No signal" takes their place and a "No bike signal" banner appears.
- Every field has its own freshness timer. Fuel, odometer and status go stale after 3 s. Stale fuel is marked "Last known".
- A missing reading shows the words "No signal", never `0`, `--` or an old number presented as live.
- Frames with a bad CRC, an out-of-order sequence or an impossible jump (more than 40 km/h in 100 ms) are rejected and counted on the signal test screen.
- Speed on screen always comes from the bike. GPS only moves the map.
- The speed numeral updates at telemetry rate, with no easing beyond a 90 ms crossfade.
- Target latency from wheel pulse to pixels: under 100 ms.

### Rider safety

- Above 5 km/h, Settings, the keyboard, place search and lists are locked. Only targets of at least 64 dp stay active.
- Locked screens unlock only after 3 s at or below 5 km/h, so they never flicker in stop-and-go traffic.
- No video, no long text and no scrolling while moving.
- Critical warnings (low fuel, engine warning, no bike signal) override everything, including navigation.
- The map is locked: no pan, zoom or rotate. It always follows the rider.

### Screens

**One dashboard.** Switching pages while riding means a hesitation, so everything lives on a single view at a 1024 dp design width that scales to the device: the status bar across the top, the instruments on the left, and the map filling the rest.

- **Status bar:** clock on the left, tell-tales in the centre, heat and bike link on the right.
- **Instruments:** the speed gauge (arc fill follows speed and turns green in Eco; chips for No signal, ECO and Stop & Start sit in its open bottom), then fuel with learned range, then the odometer line.
- **Map:** the next turn with ETA and a stop button top-left while navigating; otherwise a dismissible notice there (battery low, service due). Parked-only Settings and place search buttons top-right. Nothing sits bottom-left, so Google's logo and terms stay clear.
- **Critical alert:** covers the screen for low fuel or engine warning. The "No bike signal" banner floats under the status bar.
- **Settings** (parked only):
    - Display: theme (auto, day, night), brightness floor, reduce motion, speed alert.
    - Odometer and trips: set odometer, Trip A and Trip B with reset, next service.
    - Calibration: wheel (ride exactly 1.000 km and enter what Glance showed), fuel (save each level while filling up).
    - Signal test: every input, fuel sender mV, bike voltage, frame rate, delay, discarded and out-of-order frames, speed spikes, firmware version.
    - About: version, exit kiosk mode.
- **Trip summary** at ignition off: distance, ride time, average and top speed.
- **Parked:** dimmed, with time and date.
- **Boot:** the Glance logo fades in once.

### Navigation

- Place search with Places API (New), biased to the rider's position. Without a key, three demo routes through Colombo.
- Routes from the Routes API, asking for `TWO_WHEELER` first and falling back to `DRIVE`.
- Progress is the GPS position projected onto the route (the odometer when there is no GPS, as in Studio).
- More than 50 m off the route for 3 fixes in a row reroutes, at most once every 15 s.
- The ETA scales Google's trip time by the distance left.
- Navigation ends by itself within 30 m of the destination.

### Rider aids

| Aid | Rule |
|---|---|
| Fuel range | Learned from real riding (percent per km) and hidden until learned |
| Battery low | Below `battery_low_mv` from the vehicle profile for 30 s, so engine cranking never triggers it |
| Service reminder | Counts down to a next-service odometer reading set in Settings; shows 300 km ahead |
| Speed alert | The speed numeral turns amber above the chosen speed |

Zero means off or not yet known for every one of these.

### Tablet integration (Android)

- **Kiosk:** Glance becomes device owner, then acts as the home app, starts after reboot, hides the system bars, disables the lock screen and keeps the screen on while charging. Leave it from Settings, About, Exit kiosk mode (parked only).
- **Brightness:** follows the light sensor on a log scale between a riding floor (35 percent) and full; drops to 5 percent when parked.
- **Day and night:** day above 1,500 lux, night below 400 lux, unchanged in between so it never flickers.
- **Heat guard:** at 45 °C battery temperature, or when Android reports severe thermal status, brightness is capped at 70 percent and a heat icon shows. It releases below 41 °C.
- **Location:** GPS (or network position) once a second, used only for the map.
- Android 11 (API 30) or newer.

### Vehicle profile

Bike-specific values live in `apps/hmi/assets/vehicles/ray_zr_125.yaml`, never in code, so another bike only needs a new profile. The bike's wire measurements are recorded there too.

```yaml
name: Yamaha Ray ZR 125 Fi Hybrid
speed:
  pulses_per_rev: null
  wheel_circumference_m: null
  max_display_kmh: 100
fuel:
  low_warning_pct: null
  calibration_points: []
signals:
  eco: true
  stop_start: true
  left_indicator: true
  right_indicator: true
  high_beam: true
  fi_warning: true
  side_stand: true
electrical:
  battery_low_mv: 11800
```

`null` means not yet measured on the real bike.

### Design system: Night Road

True black, one huge calm numeral, very little colour, blue reserved for navigation. Layout, alignment and hierarchy follow Apple's CarPlay design guidelines; where they meet the safety rules above, the safety rules win.

1. **Speed is the hero.** Everything else is quiet.
2. **Colour means something.** Grey is information, blue is navigation, green is Eco and indicators, amber is attention, red is danger.
3. **True black** background.
4. **Calm motion.** Motion only shows a change of state. Nothing loops while riding.
5. **Sunlight first.** High contrast, no dim grey text on black.

| Token | Night | Day | Use |
|---|---|---|---|
| `bgBase` | `#000000` | `#F7F7F7` | Screen background |
| `bgPanel` | `#121212` | `#FFFFFF` | Main panels |
| `bgRaised` | `#191919` | `#E8E8E8` | Cards, pills |
| `bgOverlay` | `#25292E` | `#D7D7D7` | Map overlays |
| `lineSubtle` | `#31373E` | `#D7D7D7` | Borders, dividers |
| `textPrimary` | `#FFFFFF` | `#111827` | Speed, key values |
| `textSecondary` | `#E8E8E8` | `#31373E` | Labels |
| `textMuted` | `#9A9C9D` | `#7B7B7B` | Units, minor info |
| `accentNav` | `#007AFF` | `#0062CC` | Route, navigation |
| `stateEco` | `#30D158` | `#1E9E43` | Eco, healthy fuel |
| `stateWarn` | `#FFB020` | `#C77C00` | Low fuel, heat, stale data |
| `stateDanger` | `#FF453A` | `#D70015` | Engine warning, no bike signal |
| `stateIndicator` | `#30D158` | `#1E9E43` | Turn arrows |
| `stateHighBeam` | `#3D7BFF` | `#1F5FE0` | High beam |

- **Type:** speed 168, large numerals 48, medium numerals 32, title 24, body 20, caption 16 dp. Every numeral uses tabular figures so digits never jump. Nothing smaller than 16 dp while riding.
- **Space:** a 4 dp grid; 24 dp screen margin, 16 dp between modules, 24 dp inside a module.
- **Shape:** continuous (superellipse) corners, 16 dp cards, 24 dp panels, pill-shaped chips and round buttons. No shadows.
- **Motion:** 90 ms speed crossfade, 180 ms badges, 280 ms panels, 600 ms fuel bar, 1200 ms boot. Reduce motion turns motion into a crossfade or nothing.
- **Controls:** iOS-style switches, search field, stepped sliders, press feedback that dims to 40 percent, and the iOS activity indicator. No ripples and no Material progress indicators.

### Performance targets

- Steady 60 fps on the dashboard, 16 ms frame budget.
- `RepaintBoundary` around the map, the speed gauge and every gauge; gauges are custom painters.
- Cold boot to dashboard in under 15 s on the tablet.

## Installation

### Prerequisites

- Flutter **3.47.2** (Dart 3.13.2).
- Chrome, for Glance Studio.
- For the tablet: the Android SDK and an Android 11+ tablet with Google Play Services and USB debugging.
- Optional: a Google Cloud project for real maps, place search and routes. Without it, Glance draws its own map and offers three demo routes.

### 1. Get the dependencies

From the project folder:

```bash
flutter pub get
```

This is a pub workspace: run `pub get` once at the root only.

### 2. Google Maps keys (optional)

Create two API keys in the Google Cloud console and enable **Maps JavaScript API**, **Maps SDK for Android**, **Places API (New)** and **Routes API** on the project.

| Key | API restrictions | Application restriction | Where it goes |
|---|---|---|---|
| Web | Maps JavaScript API, Places API (New), Routes API | HTTP referrer `http://localhost:8080/*` | `.env.json` at the repo root, copied from `env.example.json` |
| Android | Maps SDK for Android, Places API (New), Routes API | Android app `com.example.glance` plus your signing SHA-1 | `apps/hmi/android/local.properties` as `MAPS_API_KEY=...` |

Get the SHA-1 with `./gradlew signingReport` inside `apps/hmi/android`. Release builds use the debug signing key, so one SHA-1 covers both. Keep both files local and never share them. Set a budget alert on the project.

### 3. Run Glance Studio in the browser

From `apps/hmi`:

```bash
flutter run -d chrome --web-port 8080 --dart-define=SOURCE=studio --dart-define-from-file=../../.env.json
```

Keep port 8080, because the web key only allows that referrer. Without a key, leave out `--dart-define-from-file`.

The control panel sets speed, fuel, battery, ignition, Stop & Start, indicators, high beam, FI warning, side stand and a demo navigation route, and injects faults: signal dropout, delay, jitter, corrupt CRC, speed spikes, fuel slosh, a BIM reboot and a 3 s USB unplug.

### 4. Run on the fake BIM

The fake BIM streams real protocol frames, so the full parser path runs. From the repo root:

```bash
dart run tools/fake_bim/bin/fake_bim.dart --speed 40
```

Then from `apps/hmi`:

```bash
flutter run -d chrome --dart-define=SOURCE=websocket
```

To feed a tablet over Wi-Fi, add `--lan` to the fake BIM and `--dart-define=BIM_WS_URL=ws://<pc-ip>:8787` to the app (debug and profile builds only).

| `SOURCE` | Telemetry |
|---|---|
| `simulator` (default) | Built-in simulated bike |
| `studio` | Simulated bike with the Glance Studio control panel |
| `websocket` | Fake BIM at `BIM_WS_URL` (default `ws://localhost:8787`) |

### 5. Install on an Android tablet

1. Start from a factory-fresh tablet set up **without a Google account** (device owner needs none). Enable Developer options and USB debugging.
2. From `apps/hmi`:
   ```bash
   flutter run --release --dart-define=SOURCE=simulator --dart-define-from-file=../../.env.json
   ```
3. Make Glance the device owner:
   ```bash
   adb shell dpm set-device-owner com.example.glance/.GlanceAdminReceiver
   ```
   Glance becomes the home app, starts after reboot, hides the system bars, disables the lock screen and keeps the screen on while charging.
4. To leave kiosk mode: Settings, About, Exit kiosk mode (parked only). The only other way out is a factory reset. Leaving also removes Glance as device owner, so run the `dpm set-device-owner` command again to return to kiosk mode.

## Testing

| Package | Command |
|---|---|
| `apps/hmi` | `flutter test` |
| `packages/glance_maps` | `flutter test` |
| `packages/glance_protocol` | `dart test` |
| `packages/glance_telemetry` | `dart test` |

Unit tests cover the critical flows: protocol parsing, CRC, sequence checks, freshness timers, spike rejection, the simulator, fuel range, battery watch, brightness, heat and theme policies, route geometry, rerouting, arrival and the speed gauge layout.

After a visual change, refresh the golden images from `apps/hmi` and check them by eye:

```bash
flutter test --update-goldens test/features/hmi/hmi_root_golden_test.dart
```

Frame times on a real tablet, from `apps/hmi`:

```bash
flutter test integration_test/highway_performance_test.dart --profile -d <device>
```

## Hardware

Planned for Phase 3. Nothing is connected to the bike until every wire has been identified and measured.

| Part | Choice | Purpose |
|---|---|---|
| Microcontroller | ESP32-S3-DevKitC-1 N8R8 | Signal reading; one USB-C port for the tablet, one for flashing and logs |
| Optocouplers | PC817, 6 to 8 channels | Safe reading of 12 V lamps and pulses |
| Fuel input | High-impedance op-amp buffer, divider, RC filter | Reads the fuel sender without disturbing the original meter |
| Power | Automotive 12 V to 5 V buck, 3 A, 8 to 36 V input | Powers the BIM and charges the tablet |
| Protection | 3 A inline fuse, TVS diode, reverse polarity protection | Survives spikes and load dump |
| Connectors | Waterproof (Deutsch DT or similar), T-taps or solder and heat shrink | No cutting of the bike harness |
| Enclosure | IP65 or better, in a shaded spot under the seat | Weather |
| Dash device | 7 to 8 inch Android 11+ tablet, 800+ nits, USB OTG | Sunlight readability |

The firmware will run FreeRTOS tasks for signals, odometer, link and power, with a hardware watchdog on each and a `SIM_SIGNALS` build flag that generates fake signals for desk testing. Key-off current draw target: under 1 mA.

## Roadmap

- **Phase 3:** signal discovery with an auto electrician, the BIM on a breadboard, firmware, and the `glance_serial` package (USB OTG on Android, Web Serial in Chrome, desktop serial) with reconnect in under 2 s.
- **Phase 4:** piggyback install next to the original meter, calibration, and a ride recorder for replay in Studio. Target: under 2 percent difference from the original meter over 50 km.
- **Phase 5:** final housing, visor, waterproof connectors, 30 days of real use without faults.
- **Stretch:** embedded Linux with flutter-pi and MapLibre.
- **Version 2:** GPS and 4G tracker with key-off alerts, backend, companion phone app.