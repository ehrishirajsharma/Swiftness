import Foundation

typealias Templates = [Template]

class TemplateManager {

    private static let filename = "reports.xyz"

    let contentTemplate: NSAttributedString
    var templates: Templates = []

    init() {
        contentTemplate = TemplateManager.loadContentTemplate() ?? NSAttributedString()
        load()
    }

    func createNewTemplate() {
        let template = Template()
        template.title = "Untitled"
        template.content = contentTemplate.mutableCopy() as! NSAttributedString
        templates.insert(template, at: 0)
    }

    func save() {
        let url = TemplateManager.url()
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        do {
            let data = try encoder.encode(templates)
            try data.write(to: url)
        } catch {
            print(error)
        }
    }

    func filteredTemplates(_ search: String) -> Templates {
        if search.count > 0 {
            return templates.filter{
                $0.title.lowercased().contains(search) || $0.content.string.lowercased().contains(search)
            }
        } else {
            return templates
        }
    }
}

// MARK: - Private methods
private extension TemplateManager {

    static func loadContentTemplate() -> NSAttributedString? {
        guard let rtfPath = Bundle.main.url(forResource: "ContentTemplate", withExtension: "rtf")
        else { return nil }
        do {
            let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf]
            return try NSAttributedString(url: rtfPath, options: options, documentAttributes: nil)
        } catch {
            print(error)
            return nil
        }
    }

    func load() {
        let url = TemplateManager.url()
        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            self.templates = try decoder.decode(Templates.self, from: data)
        } catch {
            print(error)
        }
    }

    static func url() -> URL {
        let fileManager = FileManager.default
        let directory = try! fileManager.url(for: .documentDirectory,
                                             in: .userDomainMask,
                                             appropriateFor: nil,
                                             create: true)
        return directory.appendingPathComponent(TemplateManager.filename)
    }
}
