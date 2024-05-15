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
    func search(master: String) async throws -> MasterSearch?
    func fetch(masterId: Int) async throws -> Master?
    func downloadImage(url imageURL: URL) async throws -> Data?
    func downloadAllImages(fromMaster master: Master) async throws -> [DiscogImage:Data]?
}

extension HTTPField.Name {
    static let oauthConsumerKey = Self("oauth_consumer_key")!
    static let oauthNonce = Self("oauth_nonce")!
    static let oauthSignature = Self("oauth_signature")! // Secret Key
    static let oauthSignatureMethod = Self("oauth_signature_method")!
    static let oauthTimestamp = Self("oauth_timestamp")!
    static let oauthCallback = Self("oauth_callback")!
}

struct DiscogsService: DiscogsServiceProtocol {
    
    //
    static let host = "api.discogs.com"
    static let token = "TqoHwznnWLnwdSykgFfKUbwTNAYpltsLOhXvENbd"
        
    func search(master: String) async throws -> MasterSearch? {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = Self.host
        urlComponents.path = "/database/search"
        urlComponents.queryItems = [URLQueryItem(name: "release_title", value: master),
                                    URLQueryItem(name: "type", value: DiscogsType.master.rawValue),
                                    URLQueryItem(name: "token", value: Self.token)]
        
        guard let url = urlComponents.url else {
            throw NetworkServicesError.invalidURL
        }
        
        var request = HTTPRequest(method: .get, url: url)
        request.headerFields[.userAgent] = "High Fidelity/0.1"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(DiscogsResponse<MasterSearch>.self, from: data)

        return response.results.first
    }
    
    func fetch(masterId: Int) async throws -> Master? {
     
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = Self.host
        urlComponents.path = "/masters/\(masterId)"
        urlComponents.queryItems = [URLQueryItem(name: "token", value: Self.token)]

        guard let url = urlComponents.url else {
            throw NetworkServicesError.invalidURL
        }
        
        var request = HTTPRequest(method: .get, url: url)
        request.headerFields[.userAgent] = "High Fidelity/0.1"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(Master.self, from: data)
     
//        print(response.jsonPrettyPrinted())

        return response
    }
    
    func downloadImage(url imageURL: URL) async throws -> Data? {
        var urlComponents = URLComponents(url: imageURL, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [URLQueryItem(name: "token", value: Self.token)]
        
        guard let url = urlComponents?.url else {
            throw NetworkServicesError.invalidURL
        }
        var request = HTTPRequest(method: .get, url: url)
        request.headerFields[.userAgent] = "High Fidelity/0.1"

        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
    
    func downloadAllImages(fromMaster master: Master) async throws -> [DiscogImage:Data]? {
        guard let images = master.images else { return nil }
        
        var allImages = [DiscogImage:Data]()

        for image in images {
            if let urlString = image.uri,
               let url = URL(string: urlString),
               let imageData = try? await downloadImage(url: url) {
                allImages[image] = imageData
            }
        }
        
        return allImages.isEmpty ? nil : allImages
    }
}

struct DiscogsResponse<T:Codable>: Codable {
    var results: [T]
    var pagination: Pagination
    
    struct Pagination: Codable {
        var pages: Int
        var per_page: Int
        var items: Int
//        var urls: [String]?
        var page: Int
    }
}

