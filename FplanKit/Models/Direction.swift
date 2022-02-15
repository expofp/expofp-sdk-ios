import Foundation

///Information about the built route
public struct Direction {
    ///Route length information. Example: "10m"
    public let distance: String
    
    ///Estimated time to complete the route
    public let duration: TimeInterval
    
    ///Start booth
    public let from: Booth
    
    ///End booth
    public let to: Booth
    
    ///Lines
    public let lines: [Line]
}
