import Foundation

class Library: Folderable {

    override init() {
        super.init()
        self.title = "New Library"
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
}
