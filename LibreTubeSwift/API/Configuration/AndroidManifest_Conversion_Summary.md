# AndroidManifest.xml to Swift Conversion Summary

## Tổng Quan

File này tóm tắt việc convert `AndroidManifest.xml` từ LibreTube Android sang cấu trúc Swift/iOS tương ứng trong thư mục `LibreTubeSwift/API/Configuration`.

## Files Đã Tạo

### 1. AppConfiguration.swift
**Mục đích**: Cấu hình chính của app
**Convert từ**: `<application>` tag và các thuộc tính
**Chức năng**:
- App info (name, bundle ID, version)
- Supported domains (YouTube, Piped)
- URL path prefixes
- App icons
- Directory paths
- Default settings

### 2. URLSchemes.swift
**Mục đích**: Xử lý deep linking và URL schemes
**Convert từ**: `<intent-filter>` tags trong RouterActivity
**Chức năng**:
- URL scheme types (YouTube, Piped, Share)
- URL content detection (video, channel, playlist, search)
- URL parsing và extraction
- Notification system cho URL handling

### 3. AppPermissions.swift
**Mục đích**: Quản lý permissions
**Convert từ**: `<uses-permission>` tags
**Chức năng**:
- Permission types và status
- Permission checking và requesting
- Required vs optional permissions
- iOS-specific permission handling

### 4. AppServices.swift
**Mục đích**: Quản lý services
**Convert từ**: `<service>` tags
**Chức năng**:
- Service types (download, player, etc.)
- Service lifecycle management
- Background task handling
- Service monitoring

### 5. Info.plist
**Mục đích**: Cấu hình iOS chính
**Convert từ**: Toàn bộ AndroidManifest.xml
**Chức năng**:
- App bundle information
- Background modes
- URL schemes và associated domains
- Privacy permissions
- Network security
- Notification categories

### 6. Entitlements.plist
**Mục đích**: iOS capabilities và entitlements
**Convert từ**: Implicit từ AndroidManifest.xml
**Chức năng**:
- App groups
- Associated domains
- Background modes
- Various iOS capabilities

### 7. ConfigurationManager.swift
**Mục đích**: Quản lý tổng hợp tất cả configurations
**Convert từ**: Tổng hợp logic từ AndroidManifest.xml
**Chức năng**:
- Setup và validation
- URL handling
- Permission management
- Service management
- Cache management
- App lifecycle handling

## Mapping Chi Tiết

### Permissions Mapping

| Android Permission | iOS Equivalent | File |
|-------------------|----------------|------|
| `INTERNET` | Always available | AppPermissions.swift |
| `ACCESS_NETWORK_STATE` | Always available | AppPermissions.swift |
| `RECEIVE_BOOT_COMPLETED` | Background App Refresh | Info.plist + AppServices.swift |
| `FOREGROUND_SERVICE` | Background Modes | Info.plist + AppServices.swift |
| `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | Background Audio | Info.plist + AppServices.swift |
| `FOREGROUND_SERVICE_DATA_SYNC` | Background Processing | Info.plist + AppServices.swift |
| `POST_NOTIFICATIONS` | UserNotifications framework | AppPermissions.swift |
| `WAKE_LOCK` | Background Modes | Info.plist |

### Activities Mapping

| Android Activity | iOS Equivalent | File |
|-----------------|----------------|------|
| `MainActivity` | Main app interface | AppConfiguration.swift |
| `RouterActivity` | URL handling | URLSchemes.swift |
| `AddToQueueActivity` | Share extension | Info.plist |
| `AddToPlaylistActivity` | Share extension | Info.plist |
| `DownloadActivity` | Share extension | Info.plist |
| `OfflinePlayerActivity` | Offline player | AppServices.swift |
| `WelcomeActivity` | Onboarding | AppConfiguration.swift |
| `SettingsActivity` | Settings | AppConfiguration.swift |
| `AboutActivity` | About | AppConfiguration.swift |
| `HelpActivity` | Help | AppConfiguration.swift |

### Services Mapping

| Android Service | iOS Equivalent | File |
|----------------|----------------|------|
| `DownloadService` | Background task | AppServices.swift |
| `PlaylistDownloadEnqueueService` | Background task | AppServices.swift |
| `OnlinePlayerService` | AVAudioSession | AppServices.swift |
| `OfflinePlayerService` | AVAudioSession | AppServices.swift |
| `OnClearFromRecentService` | App lifecycle | ConfigurationManager.swift |

### Intent Filters Mapping

| Android Intent Filter | iOS Equivalent | File |
|---------------------|----------------|------|
| `android.intent.action.VIEW` | Universal Links | Info.plist + URLSchemes.swift |
| `android.intent.action.SEND` | Share extension | Info.plist |
| `android.media.action.MEDIA_PLAY_FROM_SEARCH` | Siri integration | Info.plist |
| `android.nfc.action.NDEF_DISCOVERED` | NFC handling | Info.plist |

### URL Schemes Mapping

| Android Data | iOS Equivalent | File |
|-------------|----------------|------|
| `android:scheme="http"` | Associated domains | Info.plist |
| `android:scheme="https"` | Associated domains | Info.plist |
| `android:host="youtube.com"` | Universal links | Info.plist |
| `android:host="piped.video"` | Universal links | Info.plist |
| `android:pathPrefix="/watch"` | URL parsing | URLSchemes.swift |

## Khác Biệt Chính

### 1. Background Services
**Android**: Có foreground services chạy liên tục
**iOS**: Sử dụng background tasks và background modes có giới hạn thời gian

### 2. Permissions
**Android**: Declarative permissions trong manifest
**iOS**: Runtime permission requests với user consent

### 3. URL Handling
**Android**: Intent filters với action và data
**iOS**: Universal Links và custom URL schemes

### 4. File Access
**Android**: Có thể truy cập toàn bộ file system
**iOS**: Giới hạn trong app sandbox

### 5. Notifications
**Android**: Simple notification system
**iOS**: Complex notification categories và actions

## Cách Sử Dụng

### 1. Khởi tạo Configuration
```swift
// Trong AppDelegate hoặc SceneDelegate
ConfigurationManager.shared.initialize()
```

### 2. Xử lý URL
```swift
// Handle incoming URL
if let url = URL(string: "https://youtube.com/watch?v=123") {
    URLSchemes.handleURL(url)
}
```

### 3. Quản lý Permissions
```swift
// Check và request permissions
let permissionManager = AppPermissions.shared
permissionManager.requestRequiredPermissions { allGranted in
    if allGranted {
        print("All permissions granted")
    }
}
```

### 4. Quản lý Services
```swift
// Start services
let serviceManager = AppServices.shared
serviceManager.startService(.download)
```

## Lưu Ý Quan Trọng

1. **Background Limitations**: iOS có giới hạn nghiêm ngặt về background execution
2. **Permission Timing**: Phải request permissions tại thời điểm thích hợp
3. **URL Validation**: Cần validate URLs trước khi xử lý
4. **Memory Management**: iOS có memory pressure handling khác Android
5. **App Store Guidelines**: Tuân thủ App Store review guidelines

## Tích Hợp Vào Project

1. Thêm tất cả files vào Xcode project
2. Cấu hình Info.plist và Entitlements.plist trong project settings
3. Setup URL handling trong SceneDelegate
4. Initialize ConfigurationManager trong AppDelegate
5. Test tất cả functionality trên device thật

## Testing

### URL Handling Test
```swift
// Test YouTube URL
let youtubeURL = URL(string: "https://youtube.com/watch?v=dQw4w9WgXcQ")!
assert(URLSchemes.handleURL(youtubeURL) == true)

// Test Piped URL
let pipedURL = URL(string: "https://piped.video/watch?v=dQw4w9WgXcQ")!
assert(URLSchemes.handleURL(pipedURL) == true)
```

### Permission Test
```swift
// Test permission checking
let permissionManager = AppPermissions.shared
let status = permissionManager.checkPermission(.notifications)
assert(status != .unavailable)
```

### Service Test
```swift
// Test service management
let serviceManager = AppServices.shared
let success = serviceManager.startService(.download)
assert(success == true)

let status = serviceManager.getServiceStatus(.download)
assert(status.isRunning == true)
```

## Kết Luận

Việc convert AndroidManifest.xml sang Swift đã hoàn thành với đầy đủ functionality tương đương, được tối ưu cho iOS platform. Tất cả files đều có documentation chi tiết và examples sử dụng.