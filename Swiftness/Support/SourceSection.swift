import Foundation

class SourceSection {
    let title: String
    var data: Array<Folderable>

    init(title: String) {
        self.title = title
        self.data = []
    }
}
