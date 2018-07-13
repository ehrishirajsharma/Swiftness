import Foundation

protocol Copyable {
    init(instance: Self)
}

extension Copyable {

    func copy() -> Self {
        return Self.init(instance: self)
    }

}

extension Array where Element : Copyable {

    func copy() -> Array<Element> {
        return self.map { $0.copy() }
    }
    
}
