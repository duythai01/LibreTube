import Foundation
import UIKit

/// Configuration Manager - Tổng hợp tất cả các configuration files
public class ConfigurationManager {
    
    // MARK: - Singleton
    public static let shared = ConfigurationManager()
    
    private init() {
        setupConfiguration()
    }
    
    // MARK: - Configuration Setup
    private func setupConfiguration() {
        // Setup app configuration
        setupAppConfiguration()
        
        // Setup URL schemes
        setupURLSchemes()
        
        // Setup permissions
        setupPermissions()
        
        // Setup services
        setupServices()
        
        // Setup notifications
        setupNotifications()
    }
    
    // MARK: - App Configuration Setup
    private func setupAppConfiguration() {
        // Validate app configuration
        validateAppConfiguration()
        
        // Create necessary directories
        createAppDirectories()
        
        // Setup default settings
        setupDefaultSettings()
    }
    
    private func validateAppConfiguration() {
        // Validate bundle identifier
        guard !AppConfiguration.bundleIdentifier.isEmpty else {
            fatalError("Bundle identifier cannot be empty")
        }
        
        // Validate app name
        guard !AppConfiguration.appName.isEmpty else {
            fatalError("App name cannot be empty")
        }
        
        // Validate supported domains
        guard !AppConfiguration.supportedYouTubeDomains.isEmpty else {
            fatalError("YouTube domains cannot be empty")
        }
        
        guard !AppConfiguration.supportedPipedDomains.isEmpty else {
            fatalError("Piped domains cannot be empty")
        }
    }
    
    private func createAppDirectories() {
        let directories = [
            AppConfiguration.cacheDirectory,
            AppConfiguration.documentsDirectory,
            AppConfiguration.downloadDirectory,
            AppConfiguration.databaseDirectory
        ]
        
        for directory in directories {
            createDirectoryIfNeeded(at: directory)
        }
    }
    
    private func createDirectoryIfNeeded(at url: URL) {
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.createDirectory(
                    at: url,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                print("Created directory: \(url.path)")
            } catch {
                print("Error creating directory \(url.path): \(error)")
            }
        }
    }
    
    private func setupDefaultSettings() {
        // Setup UserDefaults with default values
        let defaults = UserDefaults.standard
        
        // App settings
        if defaults.object(forKey: "defaultInstance") == nil {
            defaults.set(AppConfiguration.Settings.defaultInstance, forKey: "defaultInstance")
        }
        
        if defaults.object(forKey: "maxCacheSize") == nil {
            defaults.set(AppConfiguration.Settings.maxCacheSize, forKey: "maxCacheSize")
        }
        
        if defaults.object(forKey: "maxDownloadConcurrency") == nil {
            defaults.set(AppConfiguration.Settings.maxDownloadConcurrency, forKey: "maxDownloadConcurrency")
        }
        
        if defaults.object(forKey: "maxPlaylistItems") == nil {
            defaults.set(AppConfiguration.Settings.maxPlaylistItems, forKey: "maxPlaylistItems")
        }
        
        if defaults.object(forKey: "autoPlayNext") == nil {
            defaults.set(AppConfiguration.Settings.autoPlayNext, forKey: "autoPlayNext")
        }
        
        if defaults.object(forKey: "backgroundPlayback") == nil {
            defaults.set(AppConfiguration.Settings.backgroundPlayback, forKey: "backgroundPlayback")
        }
        
        if defaults.object(forKey: "pictureInPicture") == nil {
            defaults.set(AppConfiguration.Settings.pictureInPicture, forKey: "pictureInPicture")
        }
    }
    
    // MARK: - URL Schemes Setup
    private func setupURLSchemes() {
        // Setup URL scheme observers
        setupURLSchemeObservers()
        
        // Validate URL schemes
        validateURLSchemes()
    }
    
    private func setupURLSchemeObservers() {
        // Listen for URL scheme notifications
        NotificationCenter.default.addObserver(
            forName: .videoURLReceived,
            object: nil,
            queue: .main
        ) { notification in
            self.handleVideoURLReceived(notification)
        }
        
        NotificationCenter.default.addObserver(
            forName: .channelURLReceived,
            object: nil,
            queue: .main
        ) { notification in
            self.handleChannelURLReceived(notification)
        }
        
        NotificationCenter.default.addObserver(
            forName: .playlistURLReceived,
            object: nil,
            queue: .main
        ) { notification in
            self.handlePlaylistURLReceived(notification)
        }
        
        NotificationCenter.default.addObserver(
            forName: .searchURLReceived,
            object: nil,
            queue: .main
        ) { notification in
            self.handleSearchURLReceived(notification)
        }
        
        NotificationCenter.default.addObserver(
            forName: .sharedTextReceived,
            object: nil,
            queue: .main
        ) { notification in
            self.handleSharedTextReceived(notification)
        }
        
        NotificationCenter.default.addObserver(
            forName: .sharedURLReceived,
            object: nil,
            queue: .main
        ) { notification in
            self.handleSharedURLReceived(notification)
        }
    }
    
    private func validateURLSchemes() {
        // Validate supported URL schemes
        guard !AppConfiguration.supportedURLSchemes.isEmpty else {
            fatalError("Supported URL schemes cannot be empty")
        }
        
        // Validate URL path prefixes
        guard !AppConfiguration.videoPathPrefixes.isEmpty else {
            fatalError("Video path prefixes cannot be empty")
        }
        
        guard !AppConfiguration.channelPathPrefixes.isEmpty else {
            fatalError("Channel path prefixes cannot be empty")
        }
        
        guard !AppConfiguration.playlistPathPrefixes.isEmpty else {
            fatalError("Playlist path prefixes cannot be empty")
        }
        
        guard !AppConfiguration.searchPathPrefixes.isEmpty else {
            fatalError("Search path prefixes cannot be empty")
        }
    }
    
    // MARK: - Permissions Setup
    private func setupPermissions() {
        // Setup permission observers
        setupPermissionObservers()
        
        // Validate permissions
        validatePermissions()
    }
    
    private func setupPermissionObservers() {
        // Monitor permission changes
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.checkPermissionsOnAppActivation()
        }
    }
    
    private func validatePermissions() {
        // Validate required permissions
        guard !AppPermissions.requiredPermissions.isEmpty else {
            fatalError("Required permissions cannot be empty")
        }
        
        // Validate optional permissions
        guard !AppPermissions.optionalPermissions.isEmpty else {
            fatalError("Optional permissions cannot be empty")
        }
    }
    
    // MARK: - Services Setup
    private func setupServices() {
        // Setup service observers
        setupServiceObservers()
        
        // Validate services
        validateServices()
    }
    
    private func setupServiceObservers() {
        // Listen for service notifications
        let serviceNotifications = [
            Notification.Name.downloadServiceStarted,
            Notification.Name.downloadServiceStopped,
            Notification.Name.playlistDownloadServiceStarted,
            Notification.Name.playlistDownloadServiceStopped,
            Notification.Name.onlinePlayerServiceStarted,
            Notification.Name.onlinePlayerServiceStopped,
            Notification.Name.offlinePlayerServiceStarted,
            Notification.Name.offlinePlayerServiceStopped,
            Notification.Name.notificationReceiverStarted,
            Notification.Name.notificationReceiverStopped,
            Notification.Name.backgroundTaskStarted,
            Notification.Name.backgroundTaskStopped
        ]
        
        for notificationName in serviceNotifications {
            NotificationCenter.default.addObserver(
                forName: notificationName,
                object: nil,
                queue: .main
            ) { notification in
                self.handleServiceNotification(notification)
            }
        }
    }
    
    private func validateServices() {
        // Validate service types
        guard !AppServices.ServiceType.allCases.isEmpty else {
            fatalError("Service types cannot be empty")
        }
    }
    
    // MARK: - Notifications Setup
    private func setupNotifications() {
        // Setup notification categories
        setupNotificationCategories()
        
        // Setup notification observers
        setupNotificationObservers()
    }
    
    private func setupNotificationCategories() {
        // Setup notification categories for download and playback
        // This would typically be done in AppDelegate or SceneDelegate
    }
    
    private func setupNotificationObservers() {
        // Listen for notification events
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.handleMemoryWarning()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.handleAppTermination()
        }
    }
    
    // MARK: - URL Handling
    private func handleVideoURLReceived(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let url = userInfo["url"] as? URL,
              let videoId = userInfo["videoId"] as? String,
              let platform = userInfo["platform"] as? String else {
            return
        }
        
        print("Video URL received: \(url)")
        print("Video ID: \(videoId)")
        print("Platform: \(platform)")
        
        // Handle video URL (e.g., open video player)
    }
    
    private func handleChannelURLReceived(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let url = userInfo["url"] as? URL,
              let channelId = userInfo["channelId"] as? String,
              let platform = userInfo["platform"] as? String else {
            return
        }
        
        print("Channel URL received: \(url)")
        print("Channel ID: \(channelId)")
        print("Platform: \(platform)")
        
        // Handle channel URL (e.g., open channel page)
    }
    
    private func handlePlaylistURLReceived(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let url = userInfo["url"] as? URL,
              let playlistId = userInfo["playlistId"] as? String,
              let platform = userInfo["platform"] as? String else {
            return
        }
        
        print("Playlist URL received: \(url)")
        print("Playlist ID: \(playlistId)")
        print("Platform: \(platform)")
        
        // Handle playlist URL (e.g., open playlist page)
    }
    
    private func handleSearchURLReceived(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let url = userInfo["url"] as? URL,
              let searchQuery = userInfo["searchQuery"] as? String,
              let platform = userInfo["platform"] as? String else {
            return
        }
        
        print("Search URL received: \(url)")
        print("Search Query: \(searchQuery)")
        print("Platform: \(platform)")
        
        // Handle search URL (e.g., open search results)
    }
    
    private func handleSharedTextReceived(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let text = userInfo["text"] as? String else {
            return
        }
        
        print("Shared text received: \(text)")
        
        // Handle shared text (e.g., parse as URL or search query)
    }
    
    private func handleSharedURLReceived(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let url = userInfo["url"] as? URL else {
            return
        }
        
        print("Shared URL received: \(url)")
        
        // Handle shared URL
        _ = URLSchemes.handleURL(url)
    }
    
    // MARK: - Permission Handling
    private func checkPermissionsOnAppActivation() {
        let permissionManager = AppPermissions.shared
        
        // Check if all required permissions are granted
        if !permissionManager.checkRequiredPermissions() {
            print("Some required permissions are not granted")
            
            // Request required permissions
            permissionManager.requestRequiredPermissions { allGranted in
                if allGranted {
                    print("All required permissions granted")
                } else {
                    print("Some required permissions were denied")
                }
            }
        }
    }
    
    // MARK: - Service Handling
    private func handleServiceNotification(_ notification: Notification) {
        print("Service notification: \(notification.name.rawValue)")
        
        // Handle service state changes
        switch notification.name {
        case .downloadServiceStarted:
            print("Download service started")
        case .downloadServiceStopped:
            print("Download service stopped")
        case .onlinePlayerServiceStarted:
            print("Online player service started")
        case .onlinePlayerServiceStopped:
            print("Online player service stopped")
        default:
            break
        }
    }
    
    // MARK: - App Lifecycle Handling
    private func handleMemoryWarning() {
        print("Memory warning received")
        
        // Clean up cache
        cleanupCache()
    }
    
    private func handleAppTermination() {
        print("App termination")
        
        // Stop all services
        AppServices.shared.stopAllServices()
        
        // Save app state
        saveAppState()
    }
    
    // MARK: - Cache Management
    private func cleanupCache() {
        let fileManager = FileManager.default
        let cacheURL = AppConfiguration.cacheDirectory
        
        do {
            let contents = try fileManager.contentsOfDirectory(
                at: cacheURL,
                includingPropertiesForKeys: [.creationDateKey, .fileSizeKey],
                options: []
            )
            
            // Sort by creation date (oldest first)
            let sortedContents = contents.sorted { url1, url2 in
                let date1 = try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate
                let date2 = try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate
                return (date1 ?? Date.distantPast) < (date2 ?? Date.distantPast)
            }
            
            // Remove oldest files if cache is too large
            var totalSize: Int64 = 0
            for url in sortedContents {
                let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                totalSize += Int64(size)
            }
            
            let maxCacheSize = UserDefaults.standard.object(forKey: "maxCacheSize") as? Int64 ?? AppConfiguration.Settings.maxCacheSize
            
            if totalSize > maxCacheSize {
                let bytesToRemove = totalSize - maxCacheSize
                var bytesRemoved: Int64 = 0
                
                for url in sortedContents {
                    if bytesRemoved >= bytesToRemove {
                        break
                    }
                    
                    let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                    try? fileManager.removeItem(at: url)
                    bytesRemoved += Int64(size)
                }
                
                print("Cleaned up \(bytesRemoved) bytes from cache")
            }
        } catch {
            print("Error cleaning up cache: \(error)")
        }
    }
    
    // MARK: - App State Management
    private func saveAppState() {
        // Save current app state to UserDefaults
        let defaults = UserDefaults.standard
        
        // Save service states
        let serviceStates = AppServices.shared.getAllServiceStatuses()
        let serviceStatesData = serviceStates.mapValues { status in
            switch status {
            case .running: return "running"
            case .stopped: return "stopped"
            case .paused: return "paused"
            case .error(let message): return "error:\(message)"
            }
        }
        
        defaults.set(serviceStatesData, forKey: "serviceStates")
        
        // Save permission states
        let permissionStates = AppPermissions.shared.getAllPermissionStatuses()
        let permissionStatesData = permissionStates.mapValues { status in
            switch status {
            case .granted: return "granted"
            case .denied: return "denied"
            case .restricted: return "restricted"
            case .notDetermined: return "notDetermined"
            case .unavailable: return "unavailable"
            }
        }
        
        defaults.set(permissionStatesData, forKey: "permissionStates")
        
        print("App state saved")
    }
    
    // MARK: - Public Interface
    public func initialize() {
        print("Configuration Manager initialized")
        print("App Name: \(AppConfiguration.appName)")
        print("Bundle ID: \(AppConfiguration.bundleIdentifier)")
        print("Version: \(AppConfiguration.version)")
        print("Build: \(AppConfiguration.buildNumber)")
    }
    
    public func cleanup() {
        // Remove observers
        NotificationCenter.default.removeObserver(self)
        
        // Stop all services
        AppServices.shared.stopAllServices()
        
        print("Configuration Manager cleaned up")
    }
}