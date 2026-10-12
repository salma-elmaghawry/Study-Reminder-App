# Session: Local Notifications — Study Reminder App

> One app, built step by step. By the end, every student has a working **Study Reminder** on their phone.

---

## The App

A student picks a time, and the app reminds them to study **every day** at that time.
Tapping the reminder opens a motivation screen.

| Screen | What's on it |
|---|---|
| **Home** | Greeting, a purple **reminder card** (time + Pick / Change / Cancel), and a **"Try it out"** list |
| **Motivation** | Opens when the user taps a notification: trophy, random motivational message, the **payload** chip, "Let's study 📖" |

### Project structure

```
lib/
├── main.dart                      # init + tap handling + MaterialApp
├── core/
│   ├── app_theme.dart             # colors + theme          (UI, give ready)
│   └── reminder_ids.dart          # notification ids
├── routing/
│   ├── routes.dart                # Routes.home, Routes.motivation
│   └── app_router.dart            # generateRoute()
├── services/
│   └── notification_service.dart  # ⭐ everything about notifications
├── screens/
│   ├── home_screen.dart           # buttons → service calls
│   └── motivation_screen.dart     # opened from a notification
└── widgets/
    ├── reminder_card.dart         # purple card               (UI, give ready)
    └── action_tile.dart           # white tile with icon      (UI, give ready)
```

> 💡 **Teaching tip:** give students `app_theme.dart`, `reminder_card.dart`, `action_tile.dart` and the Home `build()` **ready-made** at the start.
> The session time goes to `notification_service.dart`, `reminder_ids.dart`, the Home **methods**, and `main.dart`, which is the actual topic.

---

## Session Timeline

| # | Card title | Milestone in the app |
|---|---|---|
| 1 | **What & Why Notifications** | Concepts + demo of the finished app |
| 2 | **Setup & First Notification** | "Test notification now" works 🎉 |
| ☕ | **BREAK TIME** | |
| 3 | **Scheduled Notifications** | Daily reminder works, even when the app is closed |
| 4 | **Handling Notification Taps** | Tapping opens the Motivation screen |

---

## Part 1 — What & Why Notifications

**Start with the finished app.** Run Study Reminder and show the full flow: pick a time → close the app → notification → tap → Motivation screen.
Then say: *"By the end of today, this is running on your phone."*

### What is a notification?
A message shown to the user **outside** the app (status bar, lock screen), even when the app is closed.

### Why do we use them?
- **Reminders**: study time, medicine, alarms ⬅️ *our app*
- **Re-engagement**: Duolingo's "You haven't practiced today 🦉"
- **Event updates**: "Your order has arrived", "New message"

### Ways to make a notification
| Way | Who creates it | Example | When |
|---|---|---|---|
| **Local** | The device itself, no internet or server | Alarm, study reminder | **Today** |
| **Push (FCM)** | A server | WhatsApp message | Next session |
| **Background + Local** | Background code that then shows a local notification | Weather app checking hourly | WorkManager session |

**Ask:** *"Does our app need a server?"* → No. The phone already knows the time, so a **local** notification is enough.

### Types of local notifications, mapped to our app
| Type | In our app |
|---|---|
| **Instant** | ⚡ "Test notification now" |
| **Scheduled (once)** | ⏱️ "Remind me in 10 seconds" |
| **Repeating (daily)** | ⏰ The reminder card → "Pick study time" |

### Anatomy of a notification
- **`id`**: the notification's identity. Same id = replaces the old one. We also use it to cancel.
- **`title` / `body`**: the text.
- **Channel**: the category. On Android the user can turn each channel off separately. Ours is **"Study Reminders"**.
- **Payload**: hidden data attached to the notification. The user never sees it, but we read it on tap. Our app shows it on the Motivation screen.

### Permissions
Android 13+ and iOS: the user must **allow** notifications first. If they deny, nothing shows, with **no error**.

> 💡 **Analogy:** local notification = an alarm you set on your own phone. Push = someone calling you from outside.

---

## Part 2 — Setup & First Notification

**Goal:** a notification appears before the break.

### 2.1 Packages
```bash
flutter pub add flutter_local_notifications timezone flutter_timezone
```

### 2.2 Android setup
**`android/app/build.gradle.kts`**
```kotlin
compileOptions {
    isCoreLibraryDesugaringEnabled = true
    // ...
}
// end of file
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

**`AndroidManifest.xml`**: 3 permissions above `<application>`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```
Plus the 2 receivers inside `<application>`: `ScheduledNotificationReceiver` and `ScheduledNotificationBootReceiver`.

> ⚠️ **Most common mistake:** a missing receiver means scheduled notifications **silently** never show. Point at this now so it doesn't cost 20 minutes in Part 3.

### 2.3 `notification_service.dart`: channel, init, permission, show
In order:
1. **`_plugin`**: the one `FlutterLocalNotificationsPlugin` instance.
2. **`_androidDetails`**: the channel: `'study_reminders'`, `'Study Reminders'`, `Importance.max`.
   > The channel's importance and sound can't be changed from code after the first run. Uninstall the app to reset it.
3. **`init()`**: timezone setup + `InitializationSettings` + `_plugin.initialize(...)` with `onDidReceiveNotificationResponse` → `onNotificationClick`.
4. **`requestPermission()`**: Android → `requestNotificationsPermission()`, iOS → `requestPermissions(...)`.
5. **`showNotification()`**: `_plugin.show(id:, title:, body:, notificationDetails:, payload:)`.

> 📌 This is package **v22**: all parameters are **named** (`show(id: 1, ...)`). Code copied from older YouTube tutorials (`show(1, ...)`) won't compile, and that's why.

### 2.4 `reminder_ids.dart`
```dart
class ReminderIds {
  static const test = 0;
  static const quick = 1;
  static const daily = 2;
}
```
> **Why constants?** In Part 3, "Cancel" must remove **only** the daily reminder. Hardcoded numbers scattered around get mixed up.

### 2.5 `main.dart`, first version
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MyApp());
}
```

### 2.6 Home methods
- **`_allowNotifications()`** → "Allow notifications" tile → SnackBar "Allowed ✅ / Denied ❌"
- **`_testNotification()`** → "Test notification now" tile → `showNotification(id: ReminderIds.test, ..., payload: 'test_notification')`

✅ **Checkpoint:** tap **Allow notifications** → allow → tap **Test notification now** → 🎉

**Live demos:**
- Tap "Test notification now" **twice**. Only one notification shows, because it's the same `id`.
- Deny the permission on purpose (or turn it off in settings). Nothing shows and no error appears.

---

## ☕ BREAK TIME

---

## Part 3 — Scheduled Notifications

**Goal:** the daily reminder works, even with the app closed.

### 3.1 Service methods
1. **Why timezone?** "8 PM" must mean 8 PM in the **phone's** timezone. That's why `init()` calls `FlutterTimezone.getLocalTimezone()`.
2. **`_scheduleMode()`**: **exact vs inexact**. Android may delay alarms to save battery. On Android 12+ we ask for exact-alarm permission (this opens the "Alarms & reminders" settings page). If refused, we fall back to inexact.
3. **`scheduleAfter(duration:)`**: `zonedSchedule` with `tz.TZDateTime.now(tz.local).add(duration)`.
4. **`scheduleDaily(hour:, minute:)`**:
   - If the time already passed today, move it to tomorrow (the `timeAlreadyPassed` check).
   - `matchDateTimeComponents: DateTimeComponents.time` repeats it **every day**.
5. **`cancel(id)`** and **`pending()`**.

### 3.2 Home: "Remind me in 10 seconds"
**`_remindIn10Seconds()`** → `scheduleAfter(id: ReminderIds.quick, duration: Duration(seconds: 10), payload: 'quick_reminder')`

> **Demo:** tap → **close the app** → wait → it arrives.
> *"Who showed it? Not our app, it's closed. The **OS** did."*

### 3.3 Home: the reminder card
- **`_reminderTime`**: a `TimeOfDay?` in state. The card shows `--:--` / "No reminder set yet" when it's null.
- **`_pickStudyTime()`**: `showTimePicker` → `scheduleDaily(id: ReminderIds.daily, ..., payload: 'daily_reminder')` → `setState`.
  The card switches to the big time + **Change time** + **Cancel**.
- **`_cancelReminder()`**: `cancel(ReminderIds.daily)` cancels **only** the daily one → `setState(null)`.

> **Explain `mounted`:** after an `await`, the user may have left the screen. Check `mounted` before using `context` or calling `setState`.

> **Demo:** pick a time 1 minute from now → wait → it arrives. Then **Cancel** → `pending()` is empty.

✅ **Checkpoint:** the core of the app works.

---

## Part 4 — Handling Notification Taps

**Goal:** tapping a reminder opens the Motivation screen.

### 4.1 The payload
We already attached payloads: `'test_notification'`, `'quick_reminder'`, `'daily_reminder'`.
Now we **read** them. `MotivationScreen` shows the value in the payload chip.

### 4.2 Routing
- `routes.dart`: `Routes.motivation = '/motivation'`
- `app_router.dart`: `case Routes.motivation` → `MotivationScreen(payload: settings.arguments as String?)`

### 4.3 `main.dart`, final version
```dart
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  // App open (foreground/background) -> user taps a notification
  NotificationService.onNotificationClick = (payload) {
    navigatorKey.currentState?.pushNamed(Routes.motivation, arguments: payload);
  };

  // App was closed -> opened by tapping a notification
  final launchPayload = await NotificationService.getLaunchPayload();

  runApp(MyApp(launchPayload: launchPayload));
}
```
In `MaterialApp`: `navigatorKey`, and `onGenerateInitialRoutes` pushes **Home + Motivation** when `launchPayload != null`, so the ✕ button still goes back to Home.

**Explain:**
- **`navigatorKey`**: the tap callback runs **outside** the widget tree, so there's no `context`. The key lets us navigate anyway.
- **The 2 cases:**

| App state when tapped | Who handles it |
|---|---|
| Open or in background | `onNotificationClick` (from `onDidReceiveNotificationResponse`) |
| Fully closed (killed) | `getLaunchPayload()` (from `getNotificationAppLaunchDetails`) |

> **Final demo:** pick a study time → **swipe the app away** → notification arrives → tap → Motivation screen 🎉 → ✕ → Home.

✅ **Checkpoint:** Study Reminder is complete.

**Wrap-up:** *"What if the teacher wants to send a reminder to all students from a server?"* → **FCM**, next session.

---

## Common Student Errors

| Symptom | Cause |
|---|---|
| Build fails mentioning desugaring | Missing `isCoreLibraryDesugaringEnabled` / `coreLibraryDesugaring` |
| Instant works, scheduled never shows | Missing receivers in the manifest |
| Nothing shows at all | Permission denied, or the channel was turned off in settings |
| Scheduled arrives late | No exact-alarm permission → inexact mode |
| Changed importance/sound but nothing changed | Channel already created → uninstall the app |
| `show(1, 'title', ...)` doesn't compile | Old tutorial API → v22 uses named parameters |
| Tapping from a killed app opens Home only | Forgot `getLaunchPayload()` |

---

## 📝 Homework: extend Study Reminder

1. **Remember the time**: `_reminderTime` resets when the app restarts. Save it with `shared_preferences` and load it in `initState`.
2. **Reminder per subject**: Math, Physics, and so on, each with its own time, its own `id`, and its own Cancel.
3. **Weekly reminder**: e.g. only on Fridays, using `DateTimeComponents.dayOfWeekAndTime`.
4. **Bonus:** pass the subject name in the `payload` and show it on the Motivation screen ("Time for Math! 📐").
