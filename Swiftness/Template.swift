import Foundation

class Template: Codable {

    var title: String
    var content: NSAttributedString

    enum CodingKeys: String, CodingKey {
        case title, content
    }

    init() {
        self.title = ""
        self.content = NSAttributedString()
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: CodingKeys.title)
        let data = try container.decode(Data.self, forKey: CodingKeys.content)
        self.content = NSAttributedString(rtf: data, documentAttributes: nil) ?? NSAttributedString()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: CodingKeys.title)
        let data = content.rtf(from: NSRange(location: 0, length: content.length),
                               documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
        try container.encode(data, forKey: CodingKeys.content)
    }

}
