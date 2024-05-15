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

@main
struct DiscogsInfo: AsyncParsableCommand {
    @Option(name: .shortAndLong, help: "Type of search to perform")
    var type: DiscogsType
    
    @Flag(help: "Download and save release images to current directory")
    var saveImages = false
    
    @Argument(help: "The name of the [Release, Master, Artist, Label] to search for")
    var query: String
        
    mutating func run() async throws {
        let discogsService = DiscogsService()
        guard let masterSearch = try await discogsService.search(master: query) else { return }
        
        guard let master = try await discogsService.fetch(masterId: masterSearch.master_id) else { return }
        print(master.description)
        
        if saveImages {
            try await saveImages(fromMaster: master, discogsService: discogsService)
        }
    }

    func saveImages(fromMaster master: Master, discogsService: DiscogsService) async throws {
        guard master.images?.isEmpty == false else { return }
        
        guard let imageDictionary = try await discogsService.downloadAllImages(fromMaster: master) else { return }
        var count = 0
        for (discogImaage, imageData) in imageDictionary {
            if  let nsImage = NSImage(data: imageData) {
                let filename = "\(master.title!)-\(discogImaage.type)-\(count)"
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
