import ActivityKit
import WidgetKit
import SwiftUI

/// ActivityAttributes for Bus ETA Live Activity
struct BusETAAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties
        var eta: Int  // ETA in minutes
        var status: String  // Current status text (e.g., "En camino", "PARADA 5 Centro")
    }
    
    // Fixed non-changing properties
    var tripId: String
    var routeName: String
}
