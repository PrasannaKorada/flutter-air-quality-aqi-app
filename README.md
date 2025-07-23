# 🌫️ Flutter Air Quality Forecast App

![MIT License](https://img.shields.io/badge/License-MIT-green.svg)

This is a Flutter application that visualizes real-time Air Quality Index (AQI) data for Indian cities using the OpenAQ API. The app includes:

- 📍 Google Maps with AQI markers  
- 📊 Historical & 72-hour forecast AQI charts  
- 🔔 Firebase push notifications when AQI > 150  
- 🎯 Custom AQI dial UI with animated needle  
- ✅ Works for cities like Delhi, Mumbai, Bangalore, and Chennai

---

## 📱 Features

- Stream AQI data from OpenAQ.org
- Interactive Google Maps view
- Firebase Cloud Messaging for air quality alerts
- FlChart for AQI trends
- Local notifications when AQI crosses safe levels
- Responsive UI and dark mode enabled

---

## 🚀 How to Run

1. Clone the repository.
2. Ensure you have Flutter SDK (>=3.1.0).
3. Run:
   ```bash
   flutter pub get
   flutter run
