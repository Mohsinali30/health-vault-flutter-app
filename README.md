# 🏥 Health Vault

**Health Vault** is a cross-platform mobile application designed to digitize and centralize personal medical history. It empowers users to securely store prescriptions, manage family health profiles, and receive timely medication/appointment reminders, eliminating the hassle of managing fragmented physical medical records.

---

## 📱 Screenshots

| Dashboard | User Profile | Add Member | Notifications |
|:---------:|:------------:|:----------:|:-------------:|
| ![Dashboard](assets/screenshots/dashboard.png) | ![Profile](assets/screenshots/profile.png) | ![Add Member](assets/screenshots/add_member.png) | ![Notification](assets/screenshots/notification.png) |

*(Note: Replace the paths above with your actual screenshot paths)*

---

## ✨ Key Features

* **🔐 Secure Authentication:**
*  User sign-up and login powered by **Firebase Auth**.
  
* **👨‍👩‍👧‍👦 Multi-Profile Management:**
* Manage health records for the entire family (Self, Spouse, Children, Parents) under a single account.
  
  **📂 Document Storage:**
  Upload and view high-quality medical reports and prescriptions using **Supabase Storage**.
  
 **🔔 Smart Reminders:** 
 Local notification system with timezone support to remind users of upcoming appointments and medication schedules.
  
 **☁️ Hybrid Backend:** 
 Utilizes **Firebase Firestore** for real-time data syncing and **Supabase** for cost-effective file storage.
  
 **🎨 User-Friendly UI:** 
 Clean, responsive interface built with Flutter Material Design.

---

## 🛠️ Tech Stack

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **State Management:** [Provider](https://pub.dev/packages/provider)
* **Authentication:** Firebase Auth
* **Database:** Firebase Cloud Firestore
* **Storage:** Supabase Storage (S3 Compatible)
* **Notifications:** `flutter_local_notifications` + `timezone`
* **Date Formatting:** `intl`

---

## Developed with ❤️ by [Mohsin Ali]
