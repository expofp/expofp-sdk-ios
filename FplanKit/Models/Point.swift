import Foundation

///Point on floor plan
public struct Point : Decodable, Equatable{
    
    ///X coordinate
    public let x: Int
    
    ///Y coordinate
    public let y: Int
    
    /**
     This function initializes the Point struct.
      
     **Parameters:**
     - x: X coordinate
     - y: Y coordinate
     */
    public init(x: Int, y: Int){
        self.x = x
        self.y = y
    }
    
    public static func == (p1: Point, p2: Point) -> Bool {
        return p1.x == p2.x && p1.y == p2.y
    }
}
