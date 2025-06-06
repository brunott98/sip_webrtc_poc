# POCSIP

**Proof of Concept (POC)** in Flutter showcasing SIP and WebRTC integration using the **MVC pattern**.  
This project uses the following packages:

- [GetX](https://pub.dev/packages/get) – state management and routing
- [permission_handler](https://pub.dev/packages/permission_handler) – for managing runtime permissions
- [sip_ua](https://pub.dev/packages/sip_ua) – SIP protocol implementation
- [flutter_webrtc](https://pub.dev/packages/flutter_webrtc) – WebRTC support

---

## 📦 Project Configuration

### Requirements

- Java: `1.8.0_401`
- Flutter: `3.22.3`
- Dart: `3.4.4`

### Setup Instructions

To run this project, you **must create** the following configuration file 
on lib/util/config/sip_config.dart about your connection parameters.

### Code briefing
- **`AuthController`**  
  Responsible for receiving user input and performing SIP login authentication.

- **`SipRepository`**  
  Handles SIP connection logic, including registration and termination with the SIP server.

- **`CallController`**  
  Manages the state of SIP calls, including handling call lifecycle events (e.g., 
- incoming call, connected, ended).

## 🔧 Current Platform in Development
   [✅] ANDROID | [✅]IOS


