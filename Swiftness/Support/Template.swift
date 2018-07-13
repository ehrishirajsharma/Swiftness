import Foundation

class Template: Editable {

    override init() {
        super.init()
        self.title = "New Template"
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    required init(instance: Editable) {
        super.init(instance: instance)
    }
}
