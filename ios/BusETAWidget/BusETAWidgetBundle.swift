import WidgetKit
import SwiftUI

@main
struct BusETAWidgetBundle: WidgetBundle {
    var body: some Widget {
        // We only need the Live Activity for now
        BusETAWidgetLiveActivity()
    }
}
