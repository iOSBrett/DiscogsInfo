import Foundation
import ArgumentParser
import AppKit.NSImage
import Morpheus

enum DiscogsType: String, Codable, ExpressibleByArgument {
    case release
    case master
    case artist
    case label
}

enum DiscogsSort: String, Codable, ExpressibleByArgument {
    case label
    case artist
    case title
    case catno
    case format
    case rating
    case added
    case year
}


let discogsService = DiscogsService()

@main
struct DiscogsInfo: AsyncParsableCommand {

    @Option(name: .long, help: "Users token")
    var token: String?

    // MARK: Search
    @Option(name: .shortAndLong, help: "Type of search to perform")
    var type: DiscogsType?
    
    @Flag(help: "Download and save release images to current directory")
    var saveImages = false
    
    @Argument(help: "The name of the [Release, Master, Artist, Label] to search for")
    var query: String?
        
    // MARK: Collection
    @Option(name: .shortAndLong, help: "The username of the collection owner (also owner of the token)")
    var username: String?

    @Flag(help: "Lists the folders in a users collection")
    var folderList = false
   
    @Option(name: .shortAndLong, help: "Sorting criteria for results")
    var sort: DiscogsSort = .artist
    
    @Option(name: .shortAndLong, help: "The folder ID of the collection folder you want to query. 0 = All")
    var folderId: Int?

    mutating func run() async throws {
        let discogsService = DiscogsService()
        if let query {
            try await search(query: query, token: token)
        }
        
        if let username, folderList {
            if let folders = try await discogsService.fetchCollectionFolders(username: username, token: token) {
                print("\(username)'s Folders")
                for folder in folders {
                    print(" (\(folder.id)) \(folder.name): \(folder.count)")
                }
            }
        }
        
        if let username, let folderId {
            if let folderItems = try await discogsService.fetchCollectionFolderItems(folderId: folderId, sort: sort,
                                                                                     username: username, token: token) {
                print("Folder Items: \(folderItems.jsonPrettyPrinted())")
            }
        }
    }
    
    func search(query: String, token: String?) async throws {
        guard let masterSearch = try await discogsService.search(master: query) else { return }
        
        guard let master = try await discogsService.fetch(masterId: masterSearch.masterId) else { return }
        print(master.description)
        
        if saveImages {
            try await saveImages(fromMaster: master, discogsService: discogsService, token: token)
        }
    }

    func saveImages(fromMaster master: Master, discogsService: DiscogsService, token: String?) async throws {
        guard master.images?.isEmpty == false else { return }
        
        guard let imageDictionary = try await discogsService.downloadAllImages(fromMaster: master, token: token) else { return }
        var count = 0
        for (discogImaage, imageData) in imageDictionary {
            if  let nsImage = NSImage(data: imageData) {
                let filename = "\(master.title!)-\(discogImaage.type)-\(count+1)"
                let path = URL.currentDirectory().appendingPathComponent(filename, conformingTo: .png)
                print("Saving Image: \(filename)")
                nsImage.saveToPNG(withFilepath: path)
                count += 1
            }
        }
    }
}

// https://api.discogs.com/database/search?q=Jalamanta&type=release&token=TqoHwznnWLnwdSykgFfKUbwTNAYpltsLOhXvENbd
// https://api.discogs.com/database/search?q=Jalamanta&type=release&token=TqoHwznnWLnwdSykgFfKUbwTNAYpltsLOhXvENbd
