import Foundation
import Combine
import AppKit

public class SafariDownloadModel {
    public enum Error: LocalizedError {
        case openFileHandleFailed(URL, code: Int32)
        case noFolderPermission(URL)
    }
    private let decoder = PropertyListDecoder()
    
        // Get the path for the .plist file
    private func getPlistPath() -> URL? {
     let safariDownloadsAccessManager = FileAccessManager(
            allowedFileTypes: ["plist"],
            promptMessage: "Please grant read access to the plist file.",
            promptTitle: "Grant Access",
            bookmarkKey: "PlistFileBookmark",
            subFolder: "Safari",
            directoryType: .libraryDirectory
        )

        return safariDownloadsAccessManager.getFilePath()
    }
    
    func getData(fileURL: String) -> [Int64] {
        let plistPath: URL? = getPlistPath()

        if plistPath == nil {
            return [0,0]
        }

        // read plist file and get the data into the SafariDownloadFile struct

        let data = try? Data(contentsOf: plistPath!)
        
        
        if (data == nil) {
            return [0,0]
        }
        
        let file = try? decoder.decode(SafariDownloadFile.self, from: data!)
        for download in file!.DownloadHistory {
            if download.DownloadEntryPath.contains(fileURL) {
                return [Int64(download.DownloadEntryProgressBytesSoFar), Int64(download.DownloadEntryProgressTotalToLoad)]
            }
        }
        
        return [0,0]
    }
}
