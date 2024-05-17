//
//  DiscogsService.swift
//  Discogs
//
//  Created by Brett May on 12/5/2024.
//

import Foundation
import HTTPTypes
import HTTPTypesFoundation

enum NetworkServicesError : Error {
    case invalidResponse
    case invalidURL
}

protocol DiscogsServiceProtocol {
    func search(master: String, token: String?) async throws -> MasterSearch?
    func fetch(masterId: Int, token: String?) async throws -> Master?
    
    func fetchCollectionFolders(username: String, token: String?) async throws -> [Folder]?
    func fetchCollectionFolderItems(folderId: Int, sort: DiscogsSort, username: String, token: String?) async throws -> [FolderItem]?
    
    func downloadImage(url imageURL: URL, token: String?) async throws -> Data?
    func downloadAllImages(fromMaster master: Master, token: String?) async throws -> [DiscogImage:Data]?
}

struct DiscogsService: DiscogsServiceProtocol {
    //
    static let host = "api.discogs.com"
    static let token = "TqoHwznnWLnwdSykgFfKUbwTNAYpltsLOhXvENbd"
        
    func search(master: String, token: String?=nil) async throws -> MasterSearch? {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = Self.host
        urlComponents.path = "/database/search"
        urlComponents.queryItems = [URLQueryItem(name: "release_title", value: master),
                                    URLQueryItem(name: "type", value: DiscogsType.master.rawValue),
                                    URLQueryItem(name: "token", value: token ?? Self.token)]
        
        guard let url = urlComponents.url else {
            throw NetworkServicesError.invalidURL
        }
        
        var request = HTTPRequest(method: .get, url: url)
        request.headerFields[.userAgent] = "High Fidelity/0.1"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(DiscogsResponse<MasterSearch>.self, from: data)

        return response.results.first
    }
    
    func fetch(masterId: Int, token: String?=nil) async throws -> Master? {
     
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = Self.host
        urlComponents.path = "/masters/\(masterId)"
        urlComponents.queryItems = [URLQueryItem(name: "token", value: token ?? Self.token)]

        guard let url = urlComponents.url else {
            throw NetworkServicesError.invalidURL
        }
        
        var request = HTTPRequest(method: .get, url: url)
        request.headerFields[.userAgent] = "High Fidelity/0.1"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(Master.self, from: data)
        
        return response
    }
    
    // https://api.discogs.com/users/IOSBrett/collection/folders
    func fetchCollectionFolders(username: String, token: String?=nil) async throws -> [Folder]? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = Self.host
        urlComponents.path = "/users/\(username)/collection/folders"
        urlComponents.queryItems = [URLQueryItem(name: "token", value: token ?? Self.token)]

        guard let url = urlComponents.url else {
            throw NetworkServicesError.invalidURL
        }
        
        var request = HTTPRequest(method: .get, url: url)
        request.headerFields[.userAgent] = "High Fidelity/0.1"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(FolderResponse.self, from: data)

        return response.folders
    }
    
    func fetchCollectionFolderItems(folderId: Int, sort: DiscogsSort, username: String, token: String?=nil) async throws -> [FolderItem]? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = Self.host
        urlComponents.path = "/users/\(username)/collection/folders/\(folderId)/releases"
        urlComponents.queryItems = [URLQueryItem(name: "token", value: token ?? Self.token),
                                    URLQueryItem(name: "sort", value: sort.rawValue)]

        guard let url = urlComponents.url else {
            throw NetworkServicesError.invalidURL
        }
        
        print(url)
        
        var request = HTTPRequest(method: .get, url: url)
        request.headerFields[.userAgent] = "High Fidelity/0.1"
        
        let (data, _) = try await URLSession.shared.data(for: request)
//        print(data.toJSON)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(FolderItemsResponse.self, from: data)

        return response.releases
    }

    
    func downloadImage(url imageURL: URL, token: String?=nil) async throws -> Data? {
        var urlComponents = URLComponents(url: imageURL, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [URLQueryItem(name: "token", value: token ?? Self.token)]
        
        guard let url = urlComponents?.url else {
            throw NetworkServicesError.invalidURL
        }
        var request = HTTPRequest(method: .get, url: url)
        request.headerFields[.userAgent] = "High Fidelity/0.1"

        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
    
    func downloadAllImages(fromMaster master: Master, token: String?=nil) async throws -> [DiscogImage:Data]? {
        guard let images = master.images else { return nil }
        
        var allImages = [DiscogImage:Data]()

        for image in images {
            if let urlString = image.uri,
               let url = URL(string: urlString),
               let imageData = try? await downloadImage(url: url, token: token) {
                allImages[image] = imageData
            }
        }
        
        return allImages.isEmpty ? nil : allImages
    }
}

struct Pagination: Codable {
    struct Urls: Codable {
        var next: String?
        var last: String?
    }
    
    var pages: Int
    var perPage: Int?
    var items: Int
    var urls: Urls?
    var page: Int
}

struct DiscogsResponse<T:Codable>: Codable {
    var results: [T]
    var pagination: Pagination?
}




extension HTTPField.Name {
    static let oauthConsumerKey = Self("oauth_consumer_key")!
    static let oauthNonce = Self("oauth_nonce")!
    static let oauthSignature = Self("oauth_signature")! // Secret Key
    static let oauthSignatureMethod = Self("oauth_signature_method")!
    static let oauthTimestamp = Self("oauth_timestamp")!
    static let oauthCallback = Self("oauth_callback")!
}

