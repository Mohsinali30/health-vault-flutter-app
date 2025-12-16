# 🏥 Health Vault - Family Medical Profile Manager

**Health Vault** is a professional Flutter application designed to help users organize and manage medical records for themselves and their family members. It utilizes a hybrid cloud architecture, leveraging **Firebase** for real-time data and **Supabase** for secure media storage.

## ✨ Key Features

* **Family Dashboard:** A centralized grid view to manage multiple family member profiles.
* **Persistent Selection:** Set an "Active Profile" that stays selected even after the app is restarted (powered by `SharedPreferences`).
* **Dual-Cloud Integration:**
    * **Firebase Firestore:** Stores medical metadata (Blood Group, DOB, Relations).
    * **Supabase Storage:** High-performance storage for profile images and medical documents.
* **Secure Authentication:** Firebase Auth ensures each user can only access their own family vault.
* **Seamless CRUD:** Effortlessly add, edit, or remove family members with real-time UI updates.
* **Optimized Performance:** Uses the **Provider** pattern to ensure a smooth and reactive user experience.

## 🛠️ Tech Stack

| Component            | Technology Used                               |
| :------------------- | :-------------------------------------------- |
| **Framework** | [Flutter](https://flutter.dev/)               |
| **Database** | [Cloud Firestore](https://firebase.google.com)|
| **Authentication** | [Firebase Auth](https://firebase.google.com) |
| **Cloud Storage** | [Supabase Storage](https://supabase.com/)     |
| **State Management** | [Provider](https://pub.dev/packages/provider) |
| **Local Storage** | [Shared Preferences](https://pub.dev/)        |

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (`v3.0.0+` recommended)
* A Firebase Project
* A Supabase Project
