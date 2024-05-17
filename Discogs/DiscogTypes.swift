//
//  DiscogTypes.swift
//  Discogs
//
//  Created by Brett May on 15/5/2024.
//

import Foundation

// MARK: - Common

struct Artist: Codable, Identifiable {
    var id: Int
    var name: String
    var resourceUrl: String?
    var role: String?   // no idea
    var anv: String?    // no idea
    var join: String?    // no idea
    var tracks: String? // no idea
}

struct Label: Codable {
    var id: Int
    var name: String
    var resourceUrl: String?
    var entityType: String?
    var catno: String?
}

struct Track: Codable {
    var duration: String?
    var position: String
    var title: String
    var type: String
    
    enum CodingKeys: String, CodingKey {
        case duration = "duration"
        case position = "position"
        case title = "title"
        case type = "type_"
    }
}

struct MasterSearch: Codable, Identifiable {
    var id: Int
    var masterId: Int
    var masterUrl: String
    var resourceUrl: String?
    var type: String?
    var barcode: [String]?
    var catno: String?
    var genre: [String]?
    var style: [String]?
    var label: [String]?
    var country: String?
    var coverImage: String?
    var thumb: String?
    var title: String? // Deprecated?
    var format: [String]?
    var year: String?
    // User data (Mine?)
    // community
    
    struct Community: Codable {
        var have: Int
        var want: Int
    }
}

struct Master: Codable, Identifiable {
    var id: Int?
    var uri: String?
    var versionUrl: String?
    var title: String? // Deprecated?
    var artists: [Artist]?
    var genres: [String]?
    var styles: [String]?
    var year: Int?
    var dataQuality: String? // Correct
    var images: [DiscogImage]?
    var tracklist: [Track]?
}

// MARK: - Collection
// MARK: Folders

struct Folder: Codable {
    var id: Int
    var name: String
    var count: Int
    var resourceUrl: String
}

struct FolderResponse: Codable {
    var folders: [Folder]?
}

struct FolderItemsResponse: Codable {
    var releases: [FolderItem]?
    var pagination: Pagination?
}

struct FolderItem: Codable {
    struct Format: Codable {
        var qty: String
        var description: [String]?
        var name: String
    }
    struct Note: Codable {
        var fieldId: Int
        var value: String
    }
    struct BasicInformation: Codable {
        var id: Int
        var title: String
        var year: Int
        var resourceUrl: String
        var thumbUrl: String?
        var coverImage: String?
        var formats: [Format]?
        var labels: [Label]?
        var artists: [Artist]?
        var notes : [Note]?
        var genres: [String]?
        var styles: [String]?
    }
    
    var id: Int
    var instanceId: Int
    var folderId: Int
    var rating: Int
    var basicInformation: BasicInformation
}

// MARK: - Images

struct DiscogImage: Codable, Hashable {
    enum ImageType: String, Codable {
        case primary
        case secondary
    }
    var height: Int
    var width: Int
    var type: ImageType
    var resourceUrl: String?
    var uri: String?    // no idea
    var uri150: String? // no idea
}

// MARK: - Description

extension MasterSearch: CustomStringConvertible {
    var description: String {
        return "\(title ?? "") {\(year ?? "----")} (\(catno ?? "unknown"))"
    }
}

extension Master: CustomStringConvertible {
    var description: String {
        var output = ""
        
        if let title = title,
           let artist = artists?.first?.name {
            output += "\(artist) - \(title) (\(year != 0 ? String(year!) : "----"))\n"
        }
        if let tracklist = tracklist, tracklist.count > 0 {
            tracklist.forEach { track in
                output += "\(track.position) \(track.title) (\(track.duration ?? "-:--"))\n"
            }
        }
        if let genres = genres { output += "\(genres)\n" }
        if let styles = styles { output += "\(styles)\n" }
        
        return output
    }
}
