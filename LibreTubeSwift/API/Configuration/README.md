# LibreTube Swift API - Configuration

Thư mục này chứa các file cấu hình được convert từ `AndroidManifest.xml` sang Swift/iOS.

## Cấu trúc Files

### 1. AppConfiguration.swift
File cấu hình chính chứa tất cả các thông tin app được convert từ AndroidManifest.xml:

- **App Info**: Tên app, bundle identifier, version
- **URL Schemes**: Các scheme được hỗ trợ (http, https)
- **Supported Domains**: YouTube và Piped domains
- **URL Path Prefixes**: Các prefix cho video, channel, playlist, search
- **App Icons**: Các icon khác nhau của app
- **Features**: Picture-in-Picture, background audio, etc.
- **Directories**: Cache, documents, downloads, database
- **Settings**: Cấu hình mặc định

### 2. URLSchemes.swift
Xử lý deep linking và URL schemes:

- **URL Scheme Types**: YouTube, Piped, Share, Custom
- **URL Content Types**: Video, Channel, Playlist, Search
- **URL Handlers**: Xử lý các loại URL khác nhau
- **URL Parsing**: Trích xuất video ID, channel ID, playlist ID
- **Notifications**: Thông báo khi nhận URL

### 3. AppPermissions.swift
Quản lý permissions của app:

- **Permission Types**: Internet, notifications, audio, camera, etc.
- **Permission Status**: Granted, denied, restricted, not determined
- **Permission Checking**: Kiểm tra trạng thái permission
- **Permission Requesting**: Yêu cầu permission từ user
- **Required Permissions**: Permissions bắt buộc cho app

### 4. AppServices.swift
Quản lý các services của app:

- **Service Types**: Download, playlist download, online/offline player
- **Service Status**: Running, stopped, paused, error
- **Service Management**: Start, stop, pause, resume services
- **Background Tasks**: Xử lý background tasks
- **Service Monitoring**: Theo dõi trạng thái services

### 5. Info.plist
File cấu hình iOS chính:

- **App Information**: Bundle info, version, icons
- **Background Modes**: Audio, background processing, background fetch
- **URL Schemes**: Custom URL schemes
- **Associated Domains**: Universal links cho YouTube và Piped
- **Document Types**: File sharing support
- **Privacy Permissions**: Microphone, camera, photo library, location
- **Network Security**: App Transport Security settings
- **User Activity Types**: Siri integration
- **Notification Categories**: Download và playback notifications

### 6. Entitlements.plist
File entitlements cho iOS app:

- **App Groups**: Shared container access
- **Associated Domains**: Universal links
- **Background Modes**: Background capabilities
- **Network Extensions**: Multipath, WiFi info
- **Push Notifications**: APNs environment
- **Various Capabilities**: HealthKit, HomeKit, CarPlay, Siri, etc.

## Cách Sử Dụng

### 1. Khởi tạo App Configuration
```swift
// Sử dụng cấu hình mặc định
let appName = AppConfiguration.appName
let bundleId = AppConfiguration.bundleIdentifier

// Kiểm tra URL
let url = URL(string: "https://youtube.com/watch?v=123")!
if AppConfiguration.isValidYouTubeURL(url) {
    print("Valid YouTube URL")
}
```

### 2. Xử lý URL Schemes
```swift
// Handle incoming URL
let url = URL(string: "https://youtube.com/watch?v=123")!
if URLSchemes.handleURL(url) {
    print("URL handled successfully")
}

// Listen for URL notifications
NotificationCenter.default.addObserver(
    forName: .videoURLReceived,
    object: nil,
    queue: .main
) { notification in
    if let videoId = notification.userInfo?["videoId"] as? String {
        print("Received video ID: \(videoId)")
    }
}
```

### 3. Quản lý Permissions
```swift
// Check permission status
let permissionManager = AppPermissions.shared
let status = permissionManager.checkPermission(.notifications)

// Request permission
permissionManager.requestPermission(.notifications) { status in
    if status.isGranted {
        print("Notification permission granted")
    }
}

// Check all required permissions
if permissionManager.checkRequiredPermissions() {
    print("All required permissions granted")
}
```

### 4. Quản lý Services
```swift
// Start service
let serviceManager = AppServices.shared
serviceManager.startService(.download)

// Check service status
let status = serviceManager.getServiceStatus(.download)
if status.isRunning {
    print("Download service is running")
}

// Monitor service
serviceManager.monitorService(.download) { status in
    print("Download service status: \(status)")
}
```

## Mapping từ AndroidManifest.xml

### Permissions
| Android Permission | iOS Equivalent |
|-------------------|----------------|
| `INTERNET` | Always available |
| `ACCESS_NETWORK_STATE` | Always available |
| `RECEIVE_BOOT_COMPLETED` | Background App Refresh |
| `FOREGROUND_SERVICE` | Background Modes |
| `POST_NOTIFICATIONS` | UserNotifications framework |
| `WAKE_LOCK` | Background Modes |

### Activities
| Android Activity | iOS Equivalent |
|-----------------|----------------|
| `MainActivity` | Main app interface |
| `RouterActivity` | URL handling |
| `AddToQueueActivity` | Share extension |
| `AddToPlaylistActivity` | Share extension |
| `DownloadActivity` | Share extension |

### Services
| Android Service | iOS Equivalent |
|----------------|----------------|
| `DownloadService` | Background task |
| `PlaylistDownloadEnqueueService` | Background task |
| `OnlinePlayerService` | AVAudioSession |
| `OfflinePlayerService` | AVAudioSession |
| `OnClearFromRecentService` | App lifecycle |

### Intent Filters
| Android Intent Filter | iOS Equivalent |
|---------------------|----------------|
| `android.intent.action.VIEW` | Universal Links |
| `android.intent.action.SEND` | Share extension |
| `android.media.action.MEDIA_PLAY_FROM_SEARCH` | Siri integration |

## Lưu Ý Quan Trọng

1. **Background Services**: iOS không có background services như Android. Sử dụng background tasks và background modes.

2. **Permissions**: iOS yêu cầu user consent cho nhiều permissions. Luôn kiểm tra trạng thái trước khi sử dụng.

3. **URL Handling**: iOS sử dụng Universal Links thay vì intent filters. Cần cấu hình Associated Domains.

4. **File Access**: iOS sử dụng app sandbox. File access được giới hạn trong app container.

5. **Notifications**: iOS có hệ thống notification categories và actions phức tạp hơn Android.

## Tích Hợp với App

Để tích hợp các file cấu hình này vào app:

1. Thêm các file vào Xcode project
2. Cấu hình Info.plist và Entitlements.plist trong project settings
3. Khởi tạo AppConfiguration trong AppDelegate
4. Setup URL handling trong SceneDelegate
5. Request permissions khi app khởi động
6. Start services khi cần thiết

## Dependencies

Các framework cần thiết:
- Foundation
- UIKit
- AVFoundation
- MediaPlayer
- UserNotifications
- Network
- Photos
- CoreLocation
- BackgroundTasks