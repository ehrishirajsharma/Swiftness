import Foundation

class CheckListItem: Editable {

    var done = false

    private enum CodingKeys: String, CodingKey {
        case done
    }

    override init() {
        super.init()
        self.title = "New List Item"
    }

    required init(instance: Editable) {
        super.init(instance: instance)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.done = try container.decode(Bool.self, forKey: CodingKeys.done)

        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(done, forKey: CodingKeys.done)

        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }

}
