import ActivityKit
import WidgetKit
import SwiftUI

struct BusETAWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BusETAAttributes.self) { context in
            // Lock screen/banner UI
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                            .frame(width: 44, height: 44)
                        Image(systemName: "bus.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.routeName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(context.state.status)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(context.state.eta)")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                        Text("min")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Label("Actualizado hace un momento", systemImage: "clock.fill")
                    Spacer()
                    Text("BUSMEN MX")
                        .fontWeight(.heavy)
                }
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary.opacity(0.8))
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.85))
            .activitySystemActionForegroundColor(Color.orange)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Image(systemName: "bus.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.routeName)
                                .font(.caption)
                                .fontWeight(.semibold)
                            Text(context.state.status)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(spacing: 0) {
                        Text("\(context.state.eta)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.orange)
                        Text("min")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    EmptyView()
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 0) {
                        Divider()
                            .background(Color.orange.opacity(0.3))
                            .padding(.vertical, 4)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 8))
                            Text("Última actualización:")
                            Text(Date(), style: .time)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("BUSMEN")
                                .fontWeight(.black)
                                .italic()
                                .foregroundColor(.orange)
                            Text("MX")
                                .fontWeight(.bold)
                        }
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                    }
                }
                
            } compactLeading: {
                Image(systemName: "bus.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                
            } compactTrailing: {
                Text("\(context.state.eta) min")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
            } minimal: {
                VStack(spacing: 0) {
                    Image(systemName: "bus.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                    Text("\(context.state.eta)")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.orange)
                }
            }
            .keylineTint(Color.orange)
        }
    }
}
