import Foundation

public struct Route {

    let from: String
    
    let to: String
    
    let exceptInaccessible: Bool
    
    public init(from: String, to: String, exceptInaccessible: Bool){
        self.from = from
        self.to = to
        self.exceptInaccessible = exceptInaccessible
    }
}
