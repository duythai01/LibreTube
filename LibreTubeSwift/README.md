# LibreTube Swift API

Đây là phiên bản Swift của LibreTube API, được chuyển đổi từ Java/Kotlin. Thư viện này cung cấp các chức năng để tương tác với Piped API và các dịch vụ media khác.

## Cấu trúc thư mục

```
LibreTubeSwift/
├── API/
│   ├── Models/                    # Các model dữ liệu
│   │   ├── StreamItem.swift       # Model cho video items
│   │   ├── Streams.swift          # Model cho video streams
│   │   └── AdditionalModels.swift # Các model khác
│   ├── Services/                  # Các service API
│   │   ├── PipedAPIService.swift  # Service cho Piped API
│   │   ├── PipedAuthAPIService.swift # Service cho authentication
│   │   └── MediaServiceRepository.swift # Repository pattern
│   ├── Networking/                # Cấu hình networking
│   │   └── APIConfiguration.swift # Cấu hình HTTP client
│   └── Helpers/                   # Các helper functions
└── README.md
```

## Các thành phần chính

### 1. APIConfiguration
- **Chức năng**: Cấu hình HTTP client, JSON encoder/decoder, và các endpoint
- **Tương đương Java**: `RetrofitInstance.kt`
- **Dùng để**: Thiết lập cấu hình chung cho tất cả API calls

### 2. PipedAPIService
- **Chức năng**: Gọi các API cơ bản của Piped (trending, search, streams, comments, etc.)
- **Tương đương Java**: `PipedApi.kt`
- **Dùng để**: Lấy dữ liệu video, tìm kiếm, comments, channels, playlists

### 3. PipedAuthAPIService
- **Chức năng**: Xử lý authentication và các chức năng cần đăng nhập
- **Tương đương Java**: `PipedAuthApi.kt`
- **Dùng để**: Login/register, subscriptions, playlists cá nhân, feed

### 4. MediaServiceRepository
- **Chức năng**: Repository pattern để quản lý các service khác nhau
- **Tương đương Java**: `MediaServiceRepository.kt`
- **Dùng để**: Chọn service phù hợp (Piped, NewPipe, Local) dựa trên settings

## Các loại API và chức năng

### 1. Trending & Search APIs
```swift
// Lấy trending videos
let trending = mediaService.getTrending(region: "US")

// Tìm kiếm videos
let searchResults = mediaService.getSearchResults(searchQuery: "Swift tutorial", filter: "all")

// Lấy gợi ý tìm kiếm
let suggestions = mediaService.getSuggestions(query: "Swift")
```

### 2. Video Stream APIs
```swift
// Lấy thông tin chi tiết video
let streams = mediaService.getStreams(videoId: "dQw4w9WgXcQ")

// Lấy comments
let comments = mediaService.getComments(videoId: "dQw4w9WgXcQ")

// Lấy comments trang tiếp theo
let nextComments = mediaService.getCommentsNextPage(videoId: "dQw4w9WgXcQ", nextPage: "nextPageToken")
```

### 3. Sponsors & DeArrow APIs
```swift
// Lấy thông tin sponsor segments
let segments = mediaService.getSegments(videoId: "dQw4w9WgXcQ", category: ["sponsor"], actionType: ["skip"])

// Lấy DeArrow content (titles và thumbnails thay thế)
let deArrowContent = mediaService.getDeArrowContent(videoIds: "dQw4w9WgXcQ,abc123")
```

### 4. Channel APIs
```swift
// Lấy thông tin channel
let channel = mediaService.getChannel(channelId: "UC_x5XG1OV2P6uZZ5FSM9Ttw")

// Lấy channel theo tên
let channelByName = mediaService.getChannelByName(channelName: "Google Developers")

// Lấy channel tab (videos, playlists, etc.)
let channelTab = mediaService.getChannelTab(data: "channelData", nextPage: nil)
```

### 5. Playlist APIs
```swift
// Lấy thông tin playlist
let playlist = mediaService.getPlaylist(playlistId: "PLbpi6ZahtOH6BlwajRGYqrXeqReWmvFyB")

// Lấy playlist trang tiếp theo
let nextPlaylist = mediaService.getPlaylistNextPage(playlistId: "PLbpi6ZahtOH6BlwajRGYqrXeqReWmvFyB", nextPage: "nextPageToken")
```

### 6. Authentication APIs
```swift
// Login
let credentials = LoginCredentials(username: "user", password: "pass")
let token = authService.login(credentials: credentials)

// Lấy feed cá nhân
let feed = authService.getFeed(token: "userToken")

// Quản lý subscriptions
let isSubscribed = authService.isSubscribed(channelId: "channelId", token: "userToken")
let subscribe = authService.subscribe(channelId: "channelId", token: "userToken")
```

### 7. Playlist Management APIs
```swift
// Tạo playlist mới
let newPlaylist = authService.createPlaylist(name: "My Playlist", token: "userToken")

// Thêm video vào playlist
let addResult = authService.addToPlaylist(playlistId: "playlistId", videoId: "videoId", token: "userToken")

// Xóa video khỏi playlist
let removeResult = authService.removeFromPlaylist(playlistId: "playlistId", videoId: "videoId", token: "userToken")
```

## Cách sử dụng

### 1. Khởi tạo service
```swift
import Combine

// Tạo media service
let mediaService = MediaServiceRepository.createInstance()

// Tạo auth service
let authService = PipedAuthAPIService()
```

### 2. Gọi API với Combine
```swift
// Lấy trending videos
mediaService.getTrending(region: "US")
    .sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Completed")
            case .failure(let error):
                print("Error: \(error)")
            }
        },
        receiveValue: { videos in
            print("Received \(videos.count) trending videos")
        }
    )
    .store(in: &cancellables)
```

### 3. Xử lý lỗi
```swift
mediaService.getStreams(videoId: "invalidId")
    .sink(
        receiveCompletion: { completion in
            if case .failure(let error) = completion {
                switch error {
                case .httpError(let code, let message):
                    print("HTTP Error \(code): \(message)")
                case .unauthorized:
                    print("Unauthorized access")
                case .networkError(let error):
                    print("Network error: \(error)")
                default:
                    print("Unknown error: \(error)")
                }
            }
        },
        receiveValue: { streams in
            print("Video title: \(streams.title)")
        }
    )
    .store(in: &cancellables)
```

## Các model chính

### StreamItem
- Đại diện cho một video trong danh sách
- Chứa thông tin cơ bản: title, thumbnail, uploader, duration, views
- Có các computed properties: `isLive`, `isUpcoming`

### Streams
- Đại diện cho thông tin chi tiết của một video
- Chứa: audio/video streams, subtitles, chapters, related videos
- Có computed property: `isLive`

### Channel
- Đại diện cho một YouTube channel
- Chứa: thông tin channel, related streams, tabs

### Playlist
- Đại diện cho một playlist
- Chứa: danh sách videos, thông tin uploader

## Lưu ý quan trọng

1. **Error Handling**: Tất cả API calls đều trả về `AnyPublisher<T, APIError>` để xử lý lỗi một cách nhất quán.

2. **Combine Framework**: Sử dụng Combine thay vì callbacks để xử lý bất đồng bộ.

3. **Repository Pattern**: Sử dụng repository pattern để có thể dễ dàng chuyển đổi giữa các service khác nhau.

4. **Protocol-Oriented**: Sử dụng protocols để dễ dàng test và mock.

5. **Type Safety**: Tận dụng type safety của Swift với Codable protocols.

## TODO

- [ ] Implement NewPipe integration
- [ ] Implement local streams extraction
- [ ] Add preference helper để quản lý settings
- [ ] Add caching layer
- [ ] Add unit tests
- [ ] Add documentation comments
- [ ] Implement proxy support
- [ ] Add download functionality