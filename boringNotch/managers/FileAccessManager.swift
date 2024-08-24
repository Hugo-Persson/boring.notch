import Cocoa

class FileAccessManager {
    
    private let allowedFileTypes: [String]
    private let promptMessage: String
    private let promptTitle: String
    private let directoryURL: URL
    private let bookmarkKey: String
    private let subFolder: String
    
    init(allowedFileTypes: [String], promptMessage: String, promptTitle: String, bookmarkKey: String, subFolder: String, directoryType: FileManager.SearchPathDirectory, directoryDomainMask: FileManager.SearchPathDomainMask = .userDomainMask) {
        self.allowedFileTypes = allowedFileTypes
        self.promptMessage = promptMessage
        self.promptTitle = promptTitle
        self.bookmarkKey = bookmarkKey
        self.subFolder = subFolder
        
            // Get the directory URL from FileManager
        let paths = FileManager.default.urls(for: directoryType, in: directoryDomainMask)
        self.directoryURL = paths.first?.appendingPathComponent(self.subFolder) ?? URL(fileURLWithPath: "/") // Fallback to root URL if none found
    }
    
        // Main method to ensure read access to the specified file or directory
    func ensureReadAccess() {
        if hasReadAccess() {
                // If we already have access, use it
            accessFile()
        } else {
                // If we don't have access, request it
            requestReadAccess()
        }
    }
    
    func getFilePath() -> URL? {
        if let bookmarkData = UserDefaults.standard.data(forKey: bookmarkKey) {
            var isStale = false
            do {
                let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                if !isStale {
                    let _ = url.startAccessingSecurityScopedResource()
                    let fileExists = FileManager.default.fileExists(atPath: url.path)
                    if fileExists {
                        return url
                    }
                } else {
                    print("Bookmark is stale, requesting new access.")
                    requestReadAccess()
                }
            } catch {
                print("Failed to resolve the bookmark: \(error)")
            }
        } else {
            print("No bookmark found. Please request access first.")
        }
        return nil
    }
    
        // Check if we already have read access to the specified file or directory
    private func hasReadAccess() -> Bool {
        if let filePath = self.getFilePath() {
            if filePath.path.isEmpty || filePath.path == "/" {
                return false
            }
            return FileManager.default.fileExists(atPath: filePath.path)
        } else {
            return false
        }
    }
    
        // Request read access to the specified file or directory
    private func requestReadAccess() {
        DispatchQueue.main.async { // Ensure this block runs on the main thread
            let openPanel = NSOpenPanel()
            openPanel.message = self.promptMessage
            openPanel.prompt = self.promptTitle
            openPanel.allowedFileTypes = self.allowedFileTypes
            openPanel.allowsOtherFileTypes = false
            openPanel.canChooseFiles = true
            openPanel.canChooseDirectories = true
            openPanel.directoryURL = self.directoryURL
            
            openPanel.begin { response in
                if response == .OK, let selectedFileURL = openPanel.url {
                    print("File selected: \(selectedFileURL.path)")
                        // Store security-scoped bookmark for future read access
                    self.storeSecurityScopedBookmark(for: selectedFileURL)
                        // Perform actions on the selected file
                    self.accessFile()
                }
            }
        }
    }
    
        // Store a security-scoped bookmark for the given URL
    private func storeSecurityScopedBookmark(for url: URL) {
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                // Save bookmarkData to UserDefaults or another secure place
            UserDefaults.standard.set(bookmarkData, forKey: bookmarkKey)
        } catch {
            print("Failed to create security-scoped bookmark: \(error)")
        }
    }
    
        // Access the specified file or directory using the stored bookmark
    private func accessFile() {
        if let bookmarkData = UserDefaults.standard.data(forKey: bookmarkKey) {
            var isStale = false
            do {
                let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                if !isStale {
                    _ = url.startAccessingSecurityScopedResource()
                    self.readFile(at: url)
                } else {
                    print("Bookmark is stale, requesting new access.")
                    requestReadAccess()
                }
            } catch {
                print("Failed to resolve the bookmark: \(error)")
            }
        } else {
            print("No bookmark found. Please request access first.")
        }
    }
    
        // Example method to read the file
    private func readFile(at url: URL) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.path) {
            print("File access granted")
        } else {
            print("File does not exist at path: \(url.path)")
        }
    }
}
