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
    func search(release: String) async throws -> [String:String]
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
    
    func search(release: String) async throws -> [String:String] {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = Self.host
        urlComponents.path = "/database/search"
        urlComponents.queryItems = [URLQueryItem(name: "q", value: release),
                                    URLQueryItem(name: "type", value: DiscogsType.release.rawValue),
                                    URLQueryItem(name: "token", value: Self.token)]
        
        guard let url = urlComponents.url else {
            throw NetworkServicesError.invalidURL
        }
        
        print("url: \(url)")
        
        var request = HTTPRequest(method: .get, url: url)
        request.headerFields[.userAgent] = "High Fidelity/0.1"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        print(data.toJSON)
        
//        let response = try JSONDecoder().decode([String:AnyHash].self, from: data)
        return ["": ""]
    }
}

struct SearchResults: Codable {
    
}
