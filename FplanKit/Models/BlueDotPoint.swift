import Foundation

///Current position point on floor plan
public struct BlueDotPoint : Decodable, Equatable{
    
    ///X coordinate
    public let x: Int
    
    ///Y coordinate
    public let y: Int
    
    ///Floor
    public let z: String?
    
    ///Direction
    public let angle: Int?
    
    /**
     This function initializes the Point struct.
      
     **Parameters:**
     - x: X coordinate
     - y: Y coordinate
     */
    public init(x: Int, y: Int){
        self.x = x
        self.y = y
        self.z = nil
        self.angle = nil
    }
    
    /**
     This function initializes the Point struct.
      
     **Parameters:**
     - x: X coordinate
     - y: Y coordinate
     - z: Floor
     - angle: Direction
     */
    public init(x: Int, y: Int, z: String? = nil, angle: Int? = nil){
        self.x = x
        self.y = y
        self.z = z
        self.angle = angle
    }
    
    public static func == (p1: BlueDotPoint, p2: BlueDotPoint) -> Bool {
        return p1.x == p2.x && p1.y == p2.y && p1.z == p2.z && p1.angle == p2.angle
    }
}
