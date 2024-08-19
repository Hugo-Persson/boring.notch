import Cocoa

class FileAccessManager {
    
    private let allowedFileTypes: [String]
    private let promptMessage: String
    private let promptTitle: String
    private let directoryURL: URL
    private let bookmarkKey: String
    private let subFolder: String
    
    init(allowedFileTypes: [String], promptMessage: String, promptTitle: String, bookmarkKey: String,subFolder: String, directoryType: FileManager.SearchPathDirectory, directoryDomainMask: FileManager.SearchPathDomainMask = .userDomainMask) {
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


    func getFilePath() -> URL {
        if let bookmarkData = UserDefaults.standard.data(forKey: bookmarkKey) {
            var isStale = false
            if let url = try? URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale), !isStale {
                let _ = url.startAccessingSecurityScopedResource()

                let fileExists = FileManager.default.fileExists(atPath: url.path)
                if fileExists {
                    return url
                }
                
            } else {
                print("Failed to resolve the bookmark or the bookmark is stale.")
            }
        } else {
            print("No bookmark found. Please request access first.")
        }
        return URL(fileURLWithPath: "")
    }

    
        // Check if we already have read access to the specified file or directory
    private func hasReadAccess() -> Bool {
    // use self.getFilePath

    if let filePath = self.getFilePath() as URL? {
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
        let openPanel = NSOpenPanel()
        openPanel.message = promptMessage
        openPanel.prompt = promptTitle
        openPanel.allowedFileTypes = allowedFileTypes
        openPanel.allowsOtherFileTypes = false
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = true
        openPanel.directoryURL = directoryURL
        
        openPanel.begin { response in
            if response == .OK {
                if let selectedFileURL = openPanel.url {
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
            print(getFilePath())
        } catch {
            print("Failed to create security-scoped bookmark: \(error)")
        }
    }
    
        // Access the specified file or directory using the stored bookmark
    private func accessFile() {
        if let bookmarkData = UserDefaults.standard.data(forKey: bookmarkKey) {
            var isStale = false
            if let url = try? URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale), !isStale {
                _ = url.startAccessingSecurityScopedResource()
                    // Perform read actions on the file
                self.readFile(at: url)
                url.stopAccessingSecurityScopedResource()
            } else {
                print("Failed to resolve the bookmark or the bookmark is stale.")
            }
        } else {
            print("No bookmark found. Please request access first.")
        }
    }
    
        // Example method to read the file
    private func readFile(at url: URL) {
        do {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: url.path) {
                print("File acceess granted")
            } else {
                print("File does not exist at path: \(url.path)")
            }
        } catch {
            print("Failed to read file: \(error)")
        }
    }
}
