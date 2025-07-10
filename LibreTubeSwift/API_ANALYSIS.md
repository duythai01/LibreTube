# Phân tích chi tiết LibreTube API Logic

## Tổng quan về LibreTube API

LibreTube là một ứng dụng Android để xem YouTube mà không có quảng cáo, sử dụng Piped API làm backend. API được thiết kế theo kiến trúc repository pattern với nhiều service khác nhau để xử lý các chức năng khác nhau.

## Cấu trúc logic chính

### 1. Kiến trúc tổng thể

```
┌─────────────────────────────────────────────────────────────┐
│                    UI Layer (Views)                         │
├─────────────────────────────────────────────────────────────┤
│                ViewModels/ViewControllers                   │
├─────────────────────────────────────────────────────────────┤
│              Repository Layer (MediaServiceRepository)      │
├─────────────────────────────────────────────────────────────┤
│              Service Layer (PipedAPIService, etc.)          │
├─────────────────────────────────────────────────────────────┤
│              Networking Layer (URLSession, etc.)            │
├─────────────────────────────────────────────────────────────┤
│                    Piped API / NewPipe                      │
└─────────────────────────────────────────────────────────────┘
```

### 2. Các thành phần chính và chức năng

#### A. APIConfiguration (RetrofitInstance.kt)
**Chức năng:**
- Cấu hình HTTP client với OkHttp/URLSession
- Thiết lập JSON converter (Kotlinx Serialization/JSONEncoder)
- Quản lý base URLs cho các API khác nhau
- Xử lý logging cho debug mode

**Logic xử lý:**
```swift
// Tương tự như Java:
val authUrl = if (PreferenceHelper.getBoolean(PreferenceKeys.AUTH_INSTANCE_TOGGLE, false)) {
    PreferenceHelper.getString(PreferenceKeys.AUTH_INSTANCE, PIPED_API_URL)
} else {
    PipedMediaServiceRepository.apiUrl
}
```

#### B. PipedAPIService (PipedApi.kt)
**Chức năng:**
- Gọi các API cơ bản của Piped
- Xử lý trending, search, streams, comments, channels, playlists
- Không cần authentication

**Các endpoint chính:**
1. **Trending**: `/trending?region=US` - Lấy video trending theo khu vực
2. **Search**: `/search?q=query&filter=all` - Tìm kiếm video
3. **Streams**: `/streams/{videoId}` - Lấy thông tin chi tiết video
4. **Comments**: `/comments/{videoId}` - Lấy comments của video
5. **Channels**: `/channel/{channelId}` - Lấy thông tin channel
6. **Playlists**: `/playlists/{playlistId}` - Lấy thông tin playlist

#### C. PipedAuthAPIService (PipedAuthApi.kt)
**Chức năng:**
- Xử lý authentication (login/register)
- Quản lý subscriptions
- Quản lý playlists cá nhân
- Lấy feed cá nhân

**Các endpoint chính:**
1. **Authentication**: `/login`, `/register` - Đăng nhập/đăng ký
2. **Feed**: `/feed?authToken=token` - Lấy feed cá nhân
3. **Subscriptions**: `/subscribe`, `/unsubscribe` - Quản lý đăng ký
4. **Playlists**: `/user/playlists/*` - Quản lý playlist cá nhân

#### D. MediaServiceRepository (MediaServiceRepository.kt)
**Chức năng:**
- Repository pattern để quản lý các service khác nhau
- Chọn service phù hợp dựa trên settings
- Xử lý lỗi và chuyển đổi dữ liệu

**Logic chọn service:**
```swift
// Tương tự như Java:
val instance: MediaServiceRepository
    get() = when {
        PlayerHelper.fullLocalMode -> NewPipeMediaServiceRepository()
        PlayerHelper.localStreamExtraction -> LocalStreamsExtractionPipedMediaServiceRepository()
        else -> PipedMediaServiceRepository()
    }
```

## Chi tiết từng loại API

### 1. Trending & Search APIs

#### Trending API
- **Mục đích**: Lấy danh sách video đang thịnh hành
- **Logic**: Gọi Piped API với region parameter
- **Sử dụng**: Hiển thị trang chủ, khám phá nội dung

#### Search API
- **Mục đích**: Tìm kiếm video, channel, playlist
- **Logic**: 
  - Gọi API với query và filter
  - Hỗ trợ pagination với nextpage token
  - Có thể filter theo: all, videos, channels, playlists, music
- **Sử dụng**: Chức năng tìm kiếm, gợi ý

#### Suggestions API
- **Mục đích**: Lấy gợi ý tìm kiếm
- **Logic**: Gọi API với query để lấy danh sách gợi ý
- **Sử dụng**: Autocomplete trong search box

### 2. Video Stream APIs

#### Streams API
- **Mục đích**: Lấy thông tin chi tiết video để phát
- **Logic**:
  - Lấy metadata: title, description, uploader, duration
  - Lấy audio/video streams với các quality khác nhau
  - Lấy subtitles, chapters, related videos
  - Xử lý lỗi HTTP và trả về message lỗi
- **Sử dụng**: Trang xem video, player

#### Comments API
- **Mục đích**: Lấy comments của video
- **Logic**:
  - Hỗ trợ pagination với nextpage token
  - Lấy thông tin author, content, likes, replies
- **Sử dụng**: Hiển thị comments dưới video

### 3. Sponsors & DeArrow APIs

#### Sponsors API
- **Mục đích**: Lấy thông tin sponsor segments để skip
- **Logic**:
  - Gọi API với videoId và category (sponsor, intro, outro, etc.)
  - Trả về segments với thời gian bắt đầu/kết thúc
  - Có thể vote và lock segments
- **Sử dụng**: Tự động skip sponsor segments

#### DeArrow API
- **Mục đích**: Lấy titles và thumbnails thay thế
- **Logic**:
  - Gọi API với danh sách videoIds
  - Trả về titles và thumbnails được vote nhiều nhất
- **Sử dụng**: Thay thế clickbait titles/thumbnails

### 4. Channel APIs

#### Channel Info API
- **Mục đích**: Lấy thông tin channel
- **Logic**:
  - Lấy metadata: name, avatar, banner, description, subscriber count
  - Lấy related streams và tabs
  - Hỗ trợ pagination
- **Sử dụng**: Trang channel, hiển thị thông tin uploader

#### Channel Tab API
- **Mục đích**: Lấy nội dung theo tab (videos, playlists, etc.)
- **Logic**:
  - Gọi API với channel data và tab type
  - Hỗ trợ pagination
- **Sử dụng**: Hiển thị videos/playlists của channel

### 5. Playlist APIs

#### Playlist Info API
- **Mục đích**: Lấy thông tin playlist
- **Logic**:
  - Lấy metadata: name, description, thumbnail, uploader
  - Lấy danh sách videos trong playlist
  - Hỗ trợ pagination
- **Sử dụng**: Hiển thị playlist, phát playlist

### 6. Authentication APIs

#### Login/Register API
- **Mục đích**: Xác thực người dùng
- **Logic**:
  - Gửi username/password
  - Trả về token để sử dụng cho các API khác
- **Sử dụng**: Đăng nhập vào Piped account

#### Feed API
- **Mục đích**: Lấy feed cá nhân từ subscriptions
- **Logic**:
  - Gọi API với auth token
  - Trả về videos từ các channel đã subscribe
- **Sử dụng**: Trang feed cá nhân

#### Subscriptions API
- **Mục đích**: Quản lý subscriptions
- **Logic**:
  - Subscribe/unsubscribe channel
  - Lấy danh sách subscriptions
  - Import subscriptions từ YouTube
- **Sử dụng**: Quản lý đăng ký kênh

### 7. Playlist Management APIs

#### User Playlists API
- **Mục đích**: Quản lý playlists cá nhân
- **Logic**:
  - Tạo, xóa, rename playlist
  - Thêm/xóa video khỏi playlist
  - Clone playlist từ YouTube
- **Sử dụng**: Quản lý playlists cá nhân

## Xử lý lỗi và Error Handling

### Các loại lỗi chính:
1. **HTTP Errors**: 401 (Unauthorized), 500 (Server Error)
2. **Network Errors**: Kết nối mạng, timeout
3. **Decoding Errors**: Lỗi parse JSON
4. **Invalid URL**: URL không hợp lệ

### Logic xử lý lỗi:
```swift
// Tương tự như Java:
try {
    return api.getStreams(videoId)
} catch (e: HttpException) {
    val errorMessage = e.response()?.errorBody()?.string()?.runCatching {
        JsonHelper.json.decodeFromString<Message>(this).message
    }?.getOrNull()
    throw Exception(errorMessage)
}
```

## Caching và Performance

### ResettableLazy Pattern
- **Mục đích**: Cache API instances và có thể reset khi cần
- **Logic**: Sử dụng lazy initialization với khả năng reset
- **Sử dụng**: Khi thay đổi API URL hoặc cấu hình

### JSON Serialization
- **Mục đích**: Chuyển đổi JSON ↔ Objects
- **Logic**: Sử dụng Kotlinx Serialization/JSONEncoder
- **Features**: Snake case conversion, custom date serialization

## Security và Privacy

### Token Management
- **Mục đích**: Quản lý authentication tokens
- **Logic**: Lưu trữ và sử dụng tokens cho authenticated requests
- **Security**: Tokens được gửi trong Authorization header

### Proxy Support
- **Mục đích**: Hỗ trợ proxy để tránh geo-blocking
- **Logic**: Wrap URLs với proxy service
- **Sử dụng**: Cho thumbnails và avatars

## Tích hợp với các service khác

### NewPipe Integration
- **Mục đích**: Sử dụng NewPipe cho local processing
- **Logic**: Chuyển đổi giữa Piped và NewPipe dựa trên settings
- **Sử dụng**: Khi cần xử lý local hoặc offline

### Local Streams Extraction
- **Mục đích**: Trích xuất streams locally
- **Logic**: Sử dụng local processing thay vì API calls
- **Sử dụng**: Khi cần privacy cao hoặc offline mode

## Kết luận

LibreTube API được thiết kế với kiến trúc modular, sử dụng repository pattern để dễ dàng chuyển đổi giữa các service khác nhau. API hỗ trợ đầy đủ các chức năng của YouTube client với focus vào privacy và user experience.

Các điểm mạnh:
- Kiến trúc clean và modular
- Error handling tốt
- Hỗ trợ nhiều service khác nhau
- Type safety với Codable protocols
- Reactive programming với Combine

Các điểm cần cải thiện:
- Cần implement NewPipe và Local extraction
- Cần thêm caching layer
- Cần thêm unit tests
- Cần thêm documentation chi tiết hơn