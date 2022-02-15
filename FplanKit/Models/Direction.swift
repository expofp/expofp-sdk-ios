import Foundation

/**
 Route
 */
public struct Direction {
    /**
     Route length information
     Example: 10m
     */
    let distance: String
    
    /**
     Estimated time to complete the route
     */
    let duration: TimeInterval
    
    let from: Booth
    
    let to: Booth
    
    let lines: [Line]
}
