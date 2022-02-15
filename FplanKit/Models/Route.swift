import Foundation

///Route info
public struct Route {

    ///Start booth
    public let from: String
    
    ///End booth
    public let to: String
    
    ///Exclude routes inaccessible to people with disabilities
    public let exceptInaccessible: Bool
    
    /**
     This function initializes the Route struct.
      
     **Parameters:**
     - from: Start booth
     - to: End booth
     - exceptInaccessible: Exclude routes inaccessible to people with disabilities
     */
    public init(from: String, to: String, exceptInaccessible: Bool){
        self.from = from
        self.to = to
        self.exceptInaccessible = exceptInaccessible
    }
}
