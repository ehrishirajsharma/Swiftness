import Foundation

class Target: Folderable{

    override init() {
        super.init()
        self.title = "New Target"
    }

    init(library: Library) {
        super.init()
        self.title = "New Target"
        self.folders = library.folders.copy()
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
}
