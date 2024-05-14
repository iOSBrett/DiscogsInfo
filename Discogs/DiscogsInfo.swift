import Foundation
import ArgumentParser

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
    
    @Argument(help: "The search string")
    var query: String
    
    //  @Argument(
    
    mutating func run() async throws {
        let discogsService = DiscogsService()
        let response = try await discogsService.search(release: query)
        print("response: \(response)")
    }
}

// https://api.discogs.com/database/search?q=Jalamanta&type=release&token=TqoHwznnWLnwdSykgFfKUbwTNAYpltsLOhXvENbd
// https://api.discogs.com/database/search?q=Jalamanta&type=release&token=TqoHwznnWLnwdSykgFfKUbwTNAYpltsLOhXvENbd
