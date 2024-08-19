import SwiftUI
import Foundation

struct DownloadFile: Identifiable {
    let id: UUID
    let url: URL
    var progress: Double = 0.0
    var totalSize: Int64 = 0
    var progressPercentage: Double = 0.0
    var browser: BrowserType = .chromium
    var name: String {
        return url.lastPathComponent
    }
    
    var formattedSize: String {
        let totalSizeInMB = Double(totalSize) / 1_048_576.0
        return String(format: "%.2fMB", totalSizeInMB)
    }
}


class DownloadWatcher: ObservableObject {
    var alreadyNotified: Bool = false
    @Published var downloadFiles: [DownloadFile] = [] {
        didSet {
            DispatchQueue.main.async {
                
                if self.downloadFiles.isEmpty {
                    self.alreadyNotified = false
                }
                
                if !self.downloadFiles.isEmpty && !self.alreadyNotified {
                    self.vm.toggleExpandingView(status: true, type: .download, value: 0, browser: self.downloadFiles.first!.browser)
                    self.alreadyNotified = true
                }
                self.objectWillChange.send()
            }
        }
    }
    @ObservedObject var vm: BoringViewModel {
        didSet {
            if vm.enableDownloadListener {
                startWatching()
            }
        }
    }
    private var watcher: DispatchSourceFileSystemObject?
    private let folderURL: URL
    private var timer: Timer?
    private var lastCheckTime: Date
    private var timerQueue: DispatchQueue?
    private var timerSource: DispatchSourceTimer?
    
    init(vm: BoringViewModel) {
        let folders:[String] = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)
        let defaultPath = URL(fileURLWithPath: folders.first!).resolvingSymlinksInPath()
        _vm = ObservedObject(wrappedValue: vm)
        self.folderURL = defaultPath
        self.lastCheckTime = Date()
        if(self.vm.enableDownloadListener) {
            startWatching()
        }
    }
    
    private func startProgressTimer() {
        stopProgressTimer() // Ensure any existing timer is stopped
        
        timerQueue = DispatchQueue(label: "electronlabs.boringNotch.timerQueue", qos: .background)
        
        timerSource = DispatchSource.makeTimerSource(queue: timerQueue)
        timerSource?.schedule(deadline: .now(), repeating: .seconds(1))
        timerSource?.setEventHandler { [weak self] in
            self?.updateProgress()
        }
        timerSource?.resume()
    }
    
    private func stopProgressTimer() {
        timerSource?.cancel()
        timerSource = nil
        timerQueue = nil
    }
    
    private func getSafariDownloadProgress(for file: DownloadFile) -> [Int64] {
        let downloadModel = SafariDownloadModel()
        let fileTransformedUrl:String = file.url.relativePath.replacingOccurrences(of: "file://", with: "")
        return downloadModel.getData(fileURL: fileTransformedUrl)
    }
    
    
    private func updateProgress() {
        guard !downloadFiles.isEmpty else {
            stopProgressTimer()
            return
        }
        
        let fileManager = FileManager.default
        
        let copyDownloadFiles: [DownloadFile] = downloadFiles.compactMap { file in
            do {
                let attributes = try fileManager.attributesOfItem(atPath: file.url.path)
                var fileSize = file.totalSize
                
                var bytesDownloaded = attributes[.size] as? Int64 ?? 0
                
                if file.browser == .safari {
                    let downloadSizes: [Int64] = getSafariDownloadProgress(for: file)
                    bytesDownloaded = downloadSizes[0]
                    fileSize = downloadSizes[1]
                }
                
                    //                guard fileSize > 0 else { return nil }
                
                let progress = calculateProgress(bytesDownloaded: bytesDownloaded, totalSize: fileSize)
                
                    //                if progress >= 1.0 || progress.isNaN || progress.isInfinite {
                    //                    return nil // This will remove the file from tracking
                    //                }
                
                var updatedFile = file
                updatedFile.totalSize = fileSize
                updatedFile.progress = progress
                return updatedFile
                
            } catch {
                print("Error getting file attributes: \(error)")
                return nil // This will remove the file from tracking
            }
        }
        
        DispatchQueue.main.async {
            self.downloadFiles = copyDownloadFiles
            print("copyDownloadFiles", copyDownloadFiles)
            self.objectWillChange.send()
        }
    }
    
    private func calculateProgress(bytesDownloaded: Int64, totalSize: Int64) -> Double {
        guard totalSize > 0 else { return 0.0 }
        return min(Double(bytesDownloaded) / Double(totalSize), 1.0)
    }
    
    
    private func removeFileFromDownloads(file: DownloadFile) {
        downloadFiles = downloadFiles.filter { $0.url != file.url }
    }
    
    private func startWatching() {
        let folderDescriptor = open(folderURL.path, O_EVTONLY)
        
        guard folderDescriptor >= 0 else {
            print("Error opening folder: \(errno)")
            return
        }
        
        watcher = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: folderDescriptor,
            eventMask: .write,
            queue: .global(qos: .background)
        )
        
        watcher?.setEventHandler { [weak self] in
            self?.checkForNewDownloads()
        }
        
        watcher?.setCancelHandler {
            close(folderDescriptor)
        }
        
        watcher?.resume()
    }
    
    
    private func getNewFiles(since lastCheck: Date) -> [URL] {
        do {
            let fileManager = FileManager.default
            let folderContents = try fileManager.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: [.creationDateKey, .contentModificationDateKey],
                options: [.skipsHiddenFiles]
            )
            
            return folderContents.filter { url in
                guard let creationDate = try? url.resourceValues(forKeys: [.creationDateKey]).creationDate,
                      let modificationDate = try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate else {
                    return false
                }
                
                let isNewFile = creationDate > lastCheck || modificationDate > lastCheck
                let hasRelevantExtension = url.pathExtension == "crdownload" || url.pathExtension == "download"
                
                return isNewFile && hasRelevantExtension
            }
        } catch {
            print("Error getting folder contents: \(error)")
            return []
        }
    }
    
    func downloadedFromURLs(for filePath: String) -> [String]? {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: filePath) else { print("File doesn't exists"); return nil }
        
        do {
            let attributes = try fileManager.attributesOfItem(atPath: filePath)
            guard let extendedAttributes = attributes[FileAttributeKey(rawValue: "NSFileExtendedAttributes")] as? [String: Any] else {
                print("Didn't find NSFileExtendedAttributes value")
                return nil
            }
            
            guard let data = extendedAttributes["com.apple.metadata:kMDItemWhereFroms"] as? Data else {
                print("Didn't find com.apple.metadata:kMDItemWhereFroms value")
                return nil
            }
            let urls = try PropertyListDecoder().decode([String].self, from: data)
            return urls
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
    func getTotalSizeOfCrdownloadFile(at url: URL) -> Int64? {
        guard url.pathExtension == "crdownload" else {
            print("This is not a .crdownload file")
            return nil
        }
        
        do {
            let fileHandle = try FileHandle(forReadingFrom: url)
            defer {
                fileHandle.closeFile()
            }
            
                // Move to the end of the file minus 16 bytes
            try fileHandle.seek(toOffset: max(0, fileHandle.seekToEndOfFile() - 16))
            
                // Read the last 16 bytes
            guard let data = try fileHandle.read(upToCount: 16) else {
                print("Unable to read file metadata")
                return nil
            }
            
                // The total file size is stored in the last 8 bytes
            let totalSize = data.suffix(8).withUnsafeBytes { $0.load(as: Int64.self).bigEndian }
            
            let totalSizeInMB = Double(totalSize) / 1_048_576.0
            let formattedSize = String(format: "%.2f", totalSizeInMB)
            
            print("formattedSize", formattedSize)
            
            return totalSize
        } catch {
            print("Error reading file: \(error)")
            return nil
        }
    }
    
    private func checkForNewDownloads() {
        let currentTime = Date()
        let newFiles = getNewFiles(since: lastCheckTime)
        lastCheckTime = currentTime
        
        for file in newFiles {
            
            let resourceValues = try? file.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey, .totalFileAllocatedSizeKey, .fileAllocatedSizeKey])
            
            let totalSize = resourceValues?.fileSize ?? 0
            
            let newFile = DownloadFile(id: UUID(), url: file, totalSize: Int64(totalSize), browser: file.pathExtension == "download" ? .safari : .chromium)
            
            if !self.downloadFiles.contains(where: { $0.url == newFile.url }) {
                self.downloadFiles.append(newFile)
                if self.timerSource == nil {
                    self.startProgressTimer()
                }
            }
        }
        
        if newFiles.isEmpty && downloadFiles.isEmpty {
            stopProgressTimer()
        }
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    
    deinit {
        stopProgressTimer()
        watcher?.cancel()
    }
}
