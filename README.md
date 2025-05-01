# Dear Lampi: A Heartfelt Communication Experience

## Project Description

Dear Lampi aims to create a unique, emotional communication experience bringing loved ones closer using Lampi devices. The project will primarily leverage the Lampi touchscreen, pub/sub, and mobile tools that were covered throughout the course; it will not utilize the current Lampi UI control functionality.

Dear Lampi combines touch-based interactions, customizable light animations, and message exchange to allow individuals to send and receive heartfelt messages. Users can send messages that trigger personalized light effects, alerting the other user that a gift awaits them.

This project will also integrate a mobile interface developed using Swift that will allow users to craft their messages by selecting from the available images, adding custom text, and accessing their message history. Messages can only be initiated from the mobile interface. Additionally, Dear Lampi will incorporate a set of pre-programmed light effects including heartbeat, twinkle, and rainbow, adding a personal touch to each message.

## Project Plan

### Phase 1: Basic Communication & UI Setup
- Establish MQTT communication by setting topics and creating the JSON payload format.
- Develop the basic Kivy touchscreen interface for displaying messages:
  - A Dear Lampi homescreen
  - Message awaiting screen
  - Message display screen
- Implement a basic notification system using LED light effects for incoming messages.

### Phase 2: Custom Light Animations & User Profiles
- Implement custom LED patterns for different types of messages (heartbeat, twinkle, rainbow) using `pigpiod`.
- Develop a mobile app using Swift for viewing message history, crafting messages, adding friends, and light animation customization.

### Phase 3: Advanced Features & Optimization
- Enable image animations to be sent between Lampi devices.
- Improve UI for better user interaction based on user feedback.
- Add users’ unique code to profile.
- Add login/logout functionality.
- Implement storage for message history.

## Process/Methods

Before beginning development, the workflow was discussed and executed as follows:
- A shared GitHub repository was created to ensure seamless collaboration and feature integration.
- Dedicated branches were created for each partner to allow for parallel development.

Due to hardware constraints (only one team member having access to a Mac), development responsibilities were divided:
- **Lampi Side:** Focused on Kivy UI and Paho MQTT integration.
- **iOS Side:** Focused on app development in Swift and Cocoa MQTT integration.

<img width="593" alt="Screenshot 2025-05-01 at 11 22 41 AM" src="https://github.com/user-attachments/assets/810c2280-8a5c-4ca8-872b-1c9b2b5b39a6" />

### Lampi Development

Using the Figma UI designs, we implemented the three primary Dear Lampi screens—screensaver, incoming message, and display message—using Kivy’s `ScreenManager`. The Lampi subscribed to `swift/lampi/{device_ID}` via Paho MQTT to receive and unpack incoming JSON payloads containing the background, message, and alert light, triggering a screen switch to show the incoming message.

Messages were overlaid onto static images using Pillow for text rendering. For GIFs, the payload was decoded and saved as a `.gif` file, displayed with animation; static images were saved as `.png` and included the overlaid text. Users could tap the screen to transition from the incoming message screen back to the screensaver.

### Swift Development

On the mobile app side, SwiftUI was used to build the interface following the Figma designs, including friend selection, background/GIF picker, message composer, and message history views. Communication with Lampi was achieved using CocoaMQTT to publish JSON payloads to `devices/{device_ID}/swift/lampi`, containing the selected background (as base64), alert light, and optional message text.

Key features include:
- A toggle to switch between background images and GIFs.
- A `DatabaseManager` using SQLite.swift to store user accounts, friends, and messages locally.
- A unique code system for adding friends, displayed in the settings page.
- A message history view showing only messages sent by the current user.

## Results

The final implementation successfully accomplished all phases of our project plan. Our project enables communication between the iOS app and the Lampi device through MQTT brokers hosted on our EC2 instance.

Through the Dear Lampi app, the user can create their account, set their Lampi device association, and add friends by inputting their unique code. The user can then send customized messages to any of their friends by selecting a static or animated image, adding text (only to static image), and selecting an alert light mode.

The message recipient is notified of the incoming message by the LED flashing the specified light mode sequence and an animated screen on their Lampi with an “Open Me!” message. By clicking on the screen, the image and text will be displayed and continue to be displayed until the user taps the screen again to switch back to the screensaver or another incoming message is detected.

## Conclusion

Dear Lampi incorporated key concepts from the course, including pub/sub (MQTT) over EC2, iOS mobile development, and the Kivy touchscreen. This project successfully created an interactive, bidirectional messaging experience between mobile users and their physical devices.

We deepened our understanding of broker-based messaging, JSON payload handling, and platform-specific tools like CocoaMQTT for Swift. On the Lampi side, we learned to integrate Kivy features such as the `ScreenManager`, async image loading, and text overlays. Swift development strengthened our skills in building multi-screen interfaces with SwiftUI, managing state and navigation, and persisting user data with SQLite.
