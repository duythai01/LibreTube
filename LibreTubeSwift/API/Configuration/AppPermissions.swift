import Foundation
import AVFoundation
import MediaPlayer
import UserNotifications
import Network

/// App Permissions manager converted from AndroidManifest.xml
public class AppPermissions {
    
    // MARK: - Permission Types
    public enum PermissionType {
        case internet
        case networkState
        case notifications
        case audio
        case backgroundAudio
        case microphone
        case camera
        case photoLibrary
        case fileAccess
        case location
        
        public var description: String {
            switch self {
            case .internet:
                return "Internet access for streaming content"
            case .networkState:
                return "Network state monitoring"
            case .notifications:
                return "Push notifications"
            case .audio:
                return "Audio playback"
            case .backgroundAudio:
                return "Background audio playback"
            case .microphone:
                return "Microphone access"
            case .camera:
                return "Camera access"
            case .photoLibrary:
                return "Photo library access"
            case .fileAccess:
                return "File system access"
            case .location:
                return "Location access"
            }
        }
    }
    
    // MARK: - Permission Status
    public enum PermissionStatus {
        case granted
        case denied
        case restricted
        case notDetermined
        case unavailable
        
        public var isGranted: Bool {
            return self == .granted
        }
    }
    
    // MARK: - Permission Manager
    public static let shared = AppPermissions()
    
    private init() {}
    
    // MARK: - Permission Checking
    public func checkPermission(_ type: PermissionType) -> PermissionStatus {
        switch type {
        case .internet, .networkState:
            return checkNetworkPermission()
        case .notifications:
            return checkNotificationPermission()
        case .audio:
            return checkAudioPermission()
        case .backgroundAudio:
            return checkBackgroundAudioPermission()
        case .microphone:
            return checkMicrophonePermission()
        case .camera:
            return checkCameraPermission()
        case .photoLibrary:
            return checkPhotoLibraryPermission()
        case .fileAccess:
            return checkFileAccessPermission()
        case .location:
            return checkLocationPermission()
        }
    }
    
    // MARK: - Permission Requesting
    public func requestPermission(_ type: PermissionType, completion: @escaping (PermissionStatus) -> Void) {
        switch type {
        case .internet, .networkState:
            // Network permissions are always available on iOS
            completion(.granted)
        case .notifications:
            requestNotificationPermission(completion: completion)
        case .audio:
            requestAudioPermission(completion: completion)
        case .backgroundAudio:
            requestBackgroundAudioPermission(completion: completion)
        case .microphone:
            requestMicrophonePermission(completion: completion)
        case .camera:
            requestCameraPermission(completion: completion)
        case .photoLibrary:
            requestPhotoLibraryPermission(completion: completion)
        case .fileAccess:
            // File access is available through app sandbox
            completion(.granted)
        case .location:
            requestLocationPermission(completion: completion)
        }
    }
    
    // MARK: - Individual Permission Checks
    private func checkNetworkPermission() -> PermissionStatus {
        // Network access is always available on iOS
        return .granted
    }
    
    private func checkNotificationPermission() -> PermissionStatus {
        let center = UNUserNotificationCenter.current()
        var status: PermissionStatus = .notDetermined
        
        let semaphore = DispatchSemaphore(value: 0)
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                status = .granted
            case .denied:
                status = .denied
            case .notDetermined:
                status = .notDetermined
            @unknown default:
                status = .unavailable
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5.0)
        return status
    }
    
    private func checkAudioPermission() -> PermissionStatus {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            return .granted
        case .denied:
            return .denied
        case .undetermined:
            return .notDetermined
        @unknown default:
            return .unavailable
        }
    }
    
    private func checkBackgroundAudioPermission() -> PermissionStatus {
        // Background audio is controlled by background modes in Info.plist
        return .granted
    }
    
    private func checkMicrophonePermission() -> PermissionStatus {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            return .granted
        case .denied:
            return .denied
        case .undetermined:
            return .notDetermined
        @unknown default:
            return .unavailable
        }
    }
    
    private func checkCameraPermission() -> PermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .granted
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .unavailable
        }
    }
    
    private func checkPhotoLibraryPermission() -> PermissionStatus {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            return .granted
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .unavailable
        }
    }
    
    private func checkFileAccessPermission() -> PermissionStatus {
        // File access is available through app sandbox
        return .granted
    }
    
    private func checkLocationPermission() -> PermissionStatus {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            return .granted
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .unavailable
        }
    }
    
    // MARK: - Individual Permission Requests
    private func requestNotificationPermission(completion: @escaping (PermissionStatus) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted ? .granted : .denied)
            }
        }
    }
    
    private func requestAudioPermission(completion: @escaping (PermissionStatus) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted ? .granted : .denied)
            }
        }
    }
    
    private func requestBackgroundAudioPermission(completion: @escaping (PermissionStatus) -> Void) {
        // Background audio is controlled by background modes in Info.plist
        completion(.granted)
    }
    
    private func requestMicrophonePermission(completion: @escaping (PermissionStatus) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted ? .granted : .denied)
            }
        }
    }
    
    private func requestCameraPermission(completion: @escaping (PermissionStatus) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted ? .granted : .denied)
            }
        }
    }
    
    private func requestPhotoLibraryPermission(completion: @escaping (PermissionStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    completion(.granted)
                case .denied, .restricted:
                    completion(.denied)
                case .notDetermined:
                    completion(.notDetermined)
                @unknown default:
                    completion(.unavailable)
                }
            }
        }
    }
    
    private func requestLocationPermission(completion: @escaping (PermissionStatus) -> Void) {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        // Note: This is a simplified implementation. In a real app, you'd need to handle the delegate callbacks
        completion(.notDetermined)
    }
    
    // MARK: - Permission Status for All Types
    public func getAllPermissionStatuses() -> [PermissionType: PermissionStatus] {
        var statuses: [PermissionType: PermissionStatus] = [:]
        
        for type in PermissionType.allCases {
            statuses[type] = checkPermission(type)
        }
        
        return statuses
    }
    
    // MARK: - Required Permissions for LibreTube
    public static let requiredPermissions: [PermissionType] = [
        .internet,
        .networkState,
        .audio,
        .backgroundAudio
    ]
    
    public static let optionalPermissions: [PermissionType] = [
        .notifications,
        .microphone,
        .camera,
        .photoLibrary,
        .fileAccess,
        .location
    ]
    
    // MARK: - Check Required Permissions
    public func checkRequiredPermissions() -> Bool {
        for permission in AppPermissions.requiredPermissions {
            if !checkPermission(permission).isGranted {
                return false
            }
        }
        return true
    }
    
    // MARK: - Request Required Permissions
    public func requestRequiredPermissions(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var allGranted = true
        
        for permission in AppPermissions.requiredPermissions {
            group.enter()
            requestPermission(permission) { status in
                if !status.isGranted {
                    allGranted = false
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(allGranted)
        }
    }
}

// MARK: - PermissionType AllCases
extension AppPermissions.PermissionType: CaseIterable {}

// MARK: - Import Statements for Required Frameworks
import Photos
import CoreLocation