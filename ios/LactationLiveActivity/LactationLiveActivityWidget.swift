import ActivityKit
import SwiftUI
import WidgetKit

// Contrato exigido por el plugin `live_activities` (no renombrar).
struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState

    /// Debe coincidir con el `ContentState` del plugin. `contentRevision` opcional: actividades antiguas sin clave decodifican `nil`.
    public struct ContentState: Codable, Hashable {
        public var appGroupId: String
        public var contentRevision: Int64?
    }

    public var id = UUID()
}

extension LiveActivitiesAppAttributes {
    func prefixedKey(_ key: String) -> String {
        "\(id)_\(key)"
    }
}

private let lactationSharedDefaults = UserDefaults(suiteName: "group.com.controlbebe.controlBebe.liveactivity")!

/// Misma referencia que el azul biberón / Material en la app (`#2196F3`).
private let appBrandBlue = Color(red: 33 / 255, green: 150 / 255, blue: 243 / 255)

@main
struct LactationLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        LactationTimerLiveActivityWidget()
    }
}

@available(iOSApplicationExtension 16.1, *)
struct LactationTimerLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            lactationLockScreen(context: context)
        } dynamicIsland: { context in
            lactationDynamicIsland(context: context)
        }
    }

    @ViewBuilder
    private func lactationLockScreen(context: ActivityViewContext<LiveActivitiesAppAttributes>) -> some View {
        let startedAt = lactationStartedDate(context: context)
        let endAt = startedAt.addingTimeInterval(60 * 60 * 48)
        let side = lactationSharedDefaults.string(forKey: context.attributes.prefixedKey("sideLabel")) ?? "—"

        // Bloque acotado (no fila a todo el ancho de la tarjeta de bloqueo).
        HStack {
            Spacer(minLength: 0)
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mibebé")
                        .font(.headline)
                        .foregroundStyle(appBrandBlue)
                    Text(side)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                Text(timerInterval: startedAt...endAt, countsDown: false)
                    .font(.title3)
                    .monospacedDigit()
                    .foregroundStyle(appBrandBlue)
                    .multilineTextAlignment(.trailing)
            }
            .frame(maxWidth: 320)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }

    private func lactationDynamicIsland(context: ActivityViewContext<LiveActivitiesAppAttributes>) -> DynamicIsland {
        let startedAt = lactationStartedDate(context: context)
        let endAt = startedAt.addingTimeInterval(60 * 60 * 48)
        let attrs = context.attributes

        return DynamicIsland {
            DynamicIslandExpandedRegion(.center) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Mibebé")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundStyle(appBrandBlue)
                        .lineLimit(1)
                    HStack(alignment: .center, spacing: 14) {
                        Image(systemName: "timer")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(appBrandBlue)
                        Text(lactationExpandedSideLabel(attributes: attrs))
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Spacer(minLength: 8)
                        Text(timerInterval: startedAt...endAt, countsDown: false)
                            .monospacedDigit()
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundStyle(appBrandBlue)
                            .lineLimit(1)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .frame(maxWidth: 320, alignment: .leading)
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            }
        } compactLeading: {
            Image(systemName: "timer")
                .font(.system(size: 15, weight: .semibold))
                .imageScale(.medium)
                .foregroundStyle(appBrandBlue)
        } compactTrailing: {
            // Con la app en segundo plano Flutter no corre: `Text(timerInterval:)` lo anima el sistema.
            Text(timerInterval: startedAt...endAt, countsDown: false)
                .monospacedDigit()
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(appBrandBlue)
                .lineLimit(1)
                .frame(width: 50, alignment: .trailing)
        } minimal: {
            Image(systemName: "timer")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(appBrandBlue)
        }
    }

    private func lactationStartedDate(context: ActivityViewContext<LiveActivitiesAppAttributes>) -> Date {
        let ms = lactationSharedDefaults.double(forKey: context.attributes.prefixedKey("startedAtMs"))
        if ms <= 0 { return Date() }
        return Date(timeIntervalSince1970: ms / 1000.0)
    }

    /// `sideIsLeft` lo envía Flutter; si falta (actividad antigua), se intenta inferir del `sideLabel`.
    private func lactationExpandedSideLabel(attributes: LiveActivitiesAppAttributes) -> String {
        let boolKey = attributes.prefixedKey("sideIsLeft")
        if let o = lactationSharedDefaults.object(forKey: boolKey) {
            if let b = o as? Bool { return b ? "Izquierdo" : "Derecho" }
            if let n = o as? NSNumber { return n.boolValue ? "Izquierdo" : "Derecho" }
        }
        let side = lactationSharedDefaults.string(forKey: attributes.prefixedKey("sideLabel")) ?? ""
        let lower = side.lowercased()
        if lower.contains("izquierd") || lower.contains("left") { return "Izquierdo" }
        if lower.contains("derech") || lower.contains("right") { return "Derecho" }
        return "—"
    }
}
