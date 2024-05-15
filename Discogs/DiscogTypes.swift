//
//  DiscogTypes.swift
//  Discogs
//
//  Created by Brett May on 15/5/2024.
//

import Foundation

struct MasterSearch: Codable, Identifiable {
    var id: Int
    var master_id: Int
    var master_url: String
    var resource_url: String?
    var type: String?
    var barcode: [String]?
    var catno: String?
    var genre: [String]?
    var style: [String]?
    var label: [String]?
    var country: String?
    var cover_image: String?
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
    var version_url: String?
    var title: String? // Deprecated?
    var artists: [Artist]?
    var genres: [String]?
    var styles: [String]?
    var year: Int?
    var data_quality: String? // Correct
    var images: [DiscogImage]?
    var tracklist: [Track]?
    
    // This json structure may be specific to Master
    struct Artist: Codable, Identifiable {
        var id: Int
        var name: String
        var resource_url: String?
        var role: String?   // no idea
        var anv: String?    // no idea
        var join: String?    // no idea
        var tracks: String? // no idea
    }
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

struct DiscogImage: Codable, Hashable {
    enum ImageType: String, Codable {
        case primary
        case secondary
    }
    var height: Int
    var width: Int
    var type: ImageType
    var resource_url: String?
    var uri: String?    // no idea
    var uri150: String? // no idea
}



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
