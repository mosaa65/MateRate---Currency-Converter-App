# 1. Project Overview

* **Project Name:** MateRate — Currency Converter App
* **Project Type:** Cross-Platform Mobile Application
* **Business Domain:** Financial Technology / Foreign Exchange (Forex) Tools
* **Primary Purpose:** Delivers real-time global exchange rates across 160+ world currencies, offline-capable rate caching, and instant conversion for direct currency pairs and custom monetary amounts.
* **Target Users:** International travelers, financial analysts, e-commerce shoppers, and mobile users requiring fast, offline-resilient exchange rate calculations.
* **Main Business Value:** Decouples exchange rate accessibility from continuous internet connectivity using local persistent caching, provides client-side trend analysis (%Δ change computation), and incorporates a flexible ad monetization framework.

---

# 2. Resume Summary (Very Important)

* Architected and developed a cross-platform mobile currency conversion application using Flutter and Dart, querying real-time rates for 160+ world currencies via REST API.
* Implemented an offline-first data strategy using `SharedPreferences`, enabling persistent local JSON storage and client-side percentage change (%Δ) computations between cached snapshots and fresh network payloads.
* Built a fault-tolerant monetization system using a Singleton `AdManager` around Google Mobile Ads SDK, featuring frequency capping, user ad toggles, and production/test key isolation.
* Designed a modular layered architecture (`core`, `services`, `models`, `screens`, `widgets`) with native Arabic RTL support, dynamic ISO-to-Unicode flag rendering, and custom typography.

---

# 3. Core Features

* **Real-Time Global Exchange Rates:** Instant rate queries across 160+ currencies with base currency switching.
* **Offline Storage & Resilience:** Automatic local JSON snapshot persistence with fallback reads when offline or on HTTP failures.
* **Client-Side Trend Analytics:** Mathematical computation of percentage fluctuations (%Δ) between consecutive rate fetches.
* **Pair & Custom Amount Conversion:** Dedicated conversion workflows for direct currency pairs and arbitrary monetary amounts.
* **Universal Searchable Currency Picker:** Search bottom sheet filtering by ISO code or country name with dynamic Unicode flag rendering.
* **Monetization Engine & User Controls:** Integrated Google Mobile Ads (Banner, Interstitial, Rewarded) with user preference toggles.
* **Native RTL & Custom Styling:** Arabic/English UI support with Material 3 components and custom typography (Cairo, DM Serif Text).

---

# 4. Technical Stack

### Programming Languages
* Dart (^3.7.2)

### Mobile & Frontend Frameworks
* Flutter SDK (^3.7.2)
* Material Design 3
* Cupertino Icons (^1.0.8)

### Networking & External APIs
* http (^1.3.0)
* ExchangeRate-API (v6 REST Service)

### Storage & Persistence
* shared_preferences (^2.5.3)

### Monetization & Ad Utilities
* google_mobile_ads (^6.0.0)

### System & Device Integration
* connectivity_plus (^6.1.3)
* url_launcher (^6.3.1)

### Development & Build Tools
* flutter_launcher_icons (^0.14.3)
* flutter_lints (^5.0.0)

### Custom Typography & Assets
* Cairo (Cairo-SemiBold)
* DM Serif Text (DMSerifText-Regular)
* PoetsenOne
* Pacifico

---

# 5. Architecture Analysis

* **Overall Architecture Style:** Layered Architecture with clean separation between UI presentation (`screens`, `widgets`), domain models (`models`), external data services (`services`), and system constants (`core`).
* **Folder Organization:**
  * `lib/core`: System constants (`app_colors.dart`) and external credentials (`secrets.dart`).
  * `lib/models`: Data transfer objects (`ExchangeRateResponse`, `PairConversionResponse`).
  * `lib/services`: Integration handlers (`ApiService`, `AdManager`).
  * `lib/screens`: Domain views divided by feature (`home`, `conversion`, `contact`, `settings`).
  * `lib/widgets`: Shared reusable components (`UniversalCurrencyPicker`, `BarWidget`).
* **Separation of Concerns:** Business logic (rate calculation, offline caching, percentage change computation) is isolated inside `ApiService`, keeping UI widgets focused purely on presentation.
* **Design Patterns:**
  * **Singleton Pattern:** `AdManager` manages ad SDK lifecycle and prevents redundant initialization.
  * **Factory Method Pattern:** `PairConversionResponse.fromJson` encapsulates JSON parsing and numeric type coercion.
  * **Service Layer Pattern:** `ApiService` abstracts HTTP communication and local storage persistence.

---

# 6. Software Engineering Practices

* **OOP & Strong Typing:** Strongly-typed response models (`PairConversionResponse`) with explicit null-safety and getter utilities (`isSuccess`).
* **DRY (Don't Repeat Yourself):** Reusable `UniversalCurrencyPicker` bottom sheet utilized across base currency selection and conversion screens.
* **Defensive Programming & Resilience:** Asynchronous ad initialization wrapped in `try/catch` blocks ensuring ad SDK failures do not disrupt application startup.
* **Data Sanitization & Parsing Safety:** Custom `_toDouble` helper in JSON parsing logic prevents runtime `TypeError` crashes caused by API integer vs double response variations.
* **Resource Optimization:** Dynamic ISO-to-Emoji conversion (`_flagEmoji`) maps two-letter country codes to Unicode flags (`0x1F1E6`), eliminating hundreds of image assets from the application bundle.

---

# 7. Database Analysis

* **Database Engine:** Key-Value Persistent Storage (`SharedPreferences`).
* **Schema & Organization:**
  * **Rates Cache:** Stringified JSON payloads saved under `cached_rates_<BASE>`, containing rates map, timestamp, and calculated `%Δ` change map.
  * **Preferences:** Key-value pairs for `last_base_currency`, `ads_enabled`, `interstitial_every`, and `rewarded_enabled`.
* **Data Integrity & Fallback:** Automatic cache retrieval upon network timeout, connectivity loss, or non-200 HTTP responses.

---

# 8. Security Analysis

* **Authentication:** Not applicable / Not verified (Client-side utility application consuming open/key-authenticated APIs).
* **Authorization:** Not applicable / Not verified.
* **Secrets Management:** API credentials isolated in `lib/core/secrets/secrets.dart` and excluded from version control.
* **Transport Security:** Enforced HTTPS protocol for all REST API endpoints (`https://v6.exchangerate-api.com/v6/`).
* **Input Validation:** Validation inside `UniversalCurrencyPicker` preventing identical base and target currency selection.
* **Monetization Protection:** Environment isolation using official Google AdMob test Unit IDs during development mode (`testMode = true`).

---

# 9. API Analysis

* **API Style:** RESTful HTTP Services.
* **Endpoints Consumed:**
  * `latest/{base}`: Queries exchange rates for all supported currencies relative to base.
  * `pair/{base}/{target}`: Queries direct conversion rate for currency pairs.
  * `pair/{base}/{target}/{amount}`: Computes total value for specific amounts between currency pairs.
  * `codes`: Queries supported ISO currency codes and full country names.
* **Serialization & Error Handling:** Typed DTO conversion (`PairConversionResponse.fromJson`) with fallback to local cache upon network failure.

---

# 10. Deployment & Infrastructure

* **Hosting & Cloud Platform:** Not applicable (Client-side mobile application).
* **Build System:** Flutter CLI build pipeline (`flutter build apk`, `flutter build ios`, `flutter build web`).
* **CI/CD Configuration:** Not verified.
* **Docker / Containerization:** Not verified.
* **Environment Variables:** Credentials managed via Dart static constants in `lib/core/secrets/secrets.dart`.

---

# 11. Development Quality

* **Code Organization:** Clean modular structure separating presentation, services, models, and core configuration.
* **Maintainability & Readability:** High quality code with clear English variable naming, structured imports, and inline Arabic/English architectural comments.
* **Consistency:** Uniform code style following standard Flutter lint rules (`flutter_lints`).
* **Reusability:** Extensible components like `UniversalCurrencyPicker` and isolated services like `ApiService` and `AdManager`.

---

# 12. Engineering Competencies Demonstrated

* Cross-Platform Mobile Engineering (Flutter & Dart)
* RESTful API Integration & Client-Side Serialization
* Offline-First Architecture & Persistent Local Caching (`SharedPreferences`)
* Client-Side Data Analysis & Transformation (%Δ Computation)
* Software Architecture & Design Patterns (Layered Architecture, Singleton, Factory Method)
* Monetization & Ad SDK Integration (`google_mobile_ads`)
* Dynamic Localization & Native RTL Interface Support (Arabic & English)
* Defensive Programming & Error Recovery

---

# 13. ATS Resume Keywords

* **Languages & Frameworks:** Flutter, Dart, Material Design 3, REST API, JSON.
* **Architecture & Patterns:** Mobile Architecture, Layered Architecture, Clean Code, Singleton Pattern, Factory Pattern, DTO Pattern, Service Layer.
* **State & Data Management:** SharedPreferences, Offline Caching, Local Data Persistence, Data Serialization, State Management.
* **Mobile Technologies:** Google Mobile Ads, AdMob SDK, Cross-Platform Development, Dynamic Localization, RTL Support.
* **Engineering & Tools:** Git, HTTP Client, Package Management, Technical Documentation, Flutter Lints.

---

# 14. Suggested Resume Entry

**MateRate — Currency Converter App**  
*Cross-Platform Mobile Application*  

A high-performance Flutter mobile application delivering real-time exchange rates, offline resilience, and currency pair conversions across 160+ global currencies.

* Engineered a cross-platform mobile application in Flutter/Dart connecting to ExchangeRate-API REST endpoints for live market rate lookups.
* Built an offline-first caching mechanism using `SharedPreferences` to persist JSON snapshots and perform client-side percentage change (%Δ) calculations.
* Implemented a fault-tolerant `AdManager` Singleton wrapping Google Mobile Ads SDK with event-counter frequency capping and user privacy controls.
* Designed a modular layered architecture with native Arabic RTL support, dynamic ISO-to-Unicode flag rendering, and custom Material 3 typography.

**Technologies Used:** Flutter, Dart, Material Design 3, ExchangeRate-API, SharedPreferences, Google Mobile Ads (AdMob), REST APIs, Git.