//  Created by Tanaka Hiroshi on 2024/10/01.
import SwiftUI

@main
struct AltCPApp: App {
  var appState: AppState = .init()
  var appState2: AppState2 = .init()
    var body: some Scene {
        WindowGroup() {
//          WindowGroup("ChartPlot") {
            ContentView()
//            .navigationTitle("ChartPlot")
            .frame(minWidth: 500, minHeight: 400)
        }
        .environmentObject(appState)
        .environmentObject(appState2)
//        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
