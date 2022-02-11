import Foundation

/**
 Route
 */
public struct Route {
    /**
     Route length information
     Example: 10m
     */
    let distance: String
    
    /**
     Estimated time to complete the route
     */
    let duration: TimeInterval
}
