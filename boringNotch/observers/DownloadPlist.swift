//
//  Sources:SafariDownload:DownloadPlist.swift
//  boringNotch
//
//  Created by Harsh Vardhan  Goswami  on 08/08/24.
//

import Foundation

struct SafariDownloadFile:Codable {
    var DownloadHistory: [DownloadPlist]
}

struct DownloadPlist: Codable {
    var DownloadEntryProgressBytesSoFar: Int
    var DownloadEntryProgressTotalToLoad: Int
    var DownloadEntryPath: String
    var DownloadEntryDateAddedKey: Date
}
