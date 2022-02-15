import Foundation

public struct Point : Decodable {
    
    let x: Int
    
    let y: Int
    
    public init(x: Int, y: Int){
        self.x = x
        self.y = y
    }
}
