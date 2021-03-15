import Foundation

struct Episode {
    let id: Int
    let title: String
    let episodeURL: URL
}

class EpisodeModel {
    var id: Int?
    var title: String?
    var episodeURLString: String?
}

struct Mapper<Source, Destination> {
    
    enum Errors: Error {
        case imcompatibleTypes
    }
    
    private var mapping: [(Source, inout Destination) -> Void] = []
    
    mutating func map<Value>(_ sourceKeyPath: KeyPath<Source, Value>, to destinationKeyPath: ReferenceWritableKeyPath<Destination, Value>) {
        mapping.append { source, dest in
            let value = source[keyPath: sourceKeyPath]
            dest[keyPath: destinationKeyPath] = value
        }
    }
    
    mutating func map<Value>(_ sourceKeyPath: KeyPath<Source, Value>, to destinationKeyPath: ReferenceWritableKeyPath<Destination, Value?>) {
        map(sourceKeyPath, to: destinationKeyPath, transform: { $0 })
    }
    
    mutating func map<V1, V2>(_ sourceKeyPath: KeyPath<Source, V1>, to destinationKeyPath: ReferenceWritableKeyPath<Destination, V2>, transform: @escaping (V1) -> V2) {
        mapping.append { source, dest in
            let value = source[keyPath: sourceKeyPath]
            dest[keyPath: destinationKeyPath] = transform(value)
        }
    }
    
    func mapValues(from source: Source, to makeDestination: () -> Destination) throws -> Destination {
        var destination = makeDestination()
        mapping.forEach { $0(source, &destination) }
        return destination
    }
}

extension Episode {
    static var episodeModelMapper: Mapper<Episode, EpisodeModel> {
        var mapper = Mapper<Episode, EpisodeModel>()
        mapper.map(\.id, to: \.id)
        mapper.map(\.title, to: \.title)
        mapper.map(\.episodeURL, to: \.episodeURLString) { $0.absoluteString }
        return mapper
    }
}

let ep1 = Episode(id: 1, title: "First Episode", episodeURL: URL(string: "https://nsscreencast.com")!)

let mapper = Episode.episodeModelMapper
let result = try? mapper.mapValues(from: ep1, to: EpisodeModel.init)


dump(result)


