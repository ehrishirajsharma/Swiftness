import Foundation

class DataManager {

    private static let defaultURL: URL = {
        let fileManager = FileManager.default
        let directory = try! fileManager.url(for: .documentDirectory,
                                             in: .userDomainMask,
                                             appropriateFor: nil,
                                             create: true)
        return directory.appendingPathComponent(DataManager.defaultFileName).appendingPathExtension(DataManager.fileExtension)
    }()
    static let fileExtension = "swd"
    static let defaultFileName = "data"

    var targets: [Target]
    var libraries: [Library]

    init() {
        libraries = []
        targets = []
        load(url: DataManager.defaultURL)
    }

    func load(url: URL) {
        let decoder = JSONDecoder()
        guard
            let data = try? Data(contentsOf: url, options: []),
            let fileData = try? decoder.decode(FileData.self, from: data)
        else { return }

        fileData.targets?.forEach { self.targets.appendIfNotContains($0) }
        fileData.libraries?.forEach { self.libraries.appendIfNotContains($0) }
        if url != DataManager.defaultURL {
            save()
        }
    }

    func save() {
        save(targets: targets, libraries: libraries, url: DataManager.defaultURL)
    }

    func save(targets: [Target], libraries: [Library], url: URL) {
        let t = targets.count > 0 ? targets : nil
        let l = libraries.count > 0 ? libraries : nil
        let fileData = FileData(targets: t, libraries: l)
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(fileData)
            try data.write(to: url)
        } catch {
            print(error.localizedDescription)
        }

    }

}

private struct FileData: Codable {
    let targets: [Target]?
    let libraries: [Library]?

    private enum CodingKeys: String, CodingKey {
        case targets
        case libraries
    }

    init(targets: [Target]?, libraries: [Library]?) {
        self.targets = targets
        self.libraries = libraries
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.targets = try container.decodeIfPresent([Target].self, forKey: .targets)
        self.libraries = try container.decodeIfPresent([Library].self, forKey: .libraries)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let targets = targets {
            try container.encode(targets, forKey: .targets)
        }
        if let libraries = libraries {
            try container.encode(libraries, forKey: .libraries)
        }
    }
}
