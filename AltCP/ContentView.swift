//  Created by Tanaka Hiroshi on 2024/10/01.
import NWer
import SwiftUI

struct ContentView: View {
  @AppStorage("foo") var selStr: String = "0000,6952,9432,1301,130A"
  var sels: Queue<String> { str2Que(selStr) }
  @EnvironmentObject var env: AppState
  var body: some View {
    if let text = env.selection {
      singlePlot(text)
    } else {
      let _ = print("\n <-- Start Plot\n")
      let _ = print("selStr: \(selStr), sels: \(sels.count)")
      multiPlot()
    }
  }
  //
  private func multiPlot() -> some View {
    ScrollView(.vertical) {
      LazyVGrid(columns: columns, spacing: 10) {
        ForEach(sels.ar, id: \.self) {e in
          StockView(selection: .constant(e), typ: env.typ)
            .onLongPressGesture {
              env.selection = e
            }
            .frame(height: CHARTWIDTH*0.75)
            .padding(5)
        }
      }
    } // ScrollView
    .modifier(TitleBarMnu(limit: $env.limit))
    .modifier(TitleBarBtn(typ: $env.typ))
    .navigationTitle(env.titleBar)
    .padding(.bottom, 4.5)
    .padding([.top, .leading, .trailing], 3)
  }
  private func singlePlot(_ text: String) -> some View {
    StockView(selection: $env.selection, typ: env.typ)
//    StockView(selected: text, selection: $env.selection)
      .onLongPressGesture {
        env.selection = nil
      }
      .modifier(TitleBarMnu(limit: $env.limit))
      .modifier(TitleBarBtn(typ: $env.typ))
      .navigationTitle(env.titleBar)
      .padding(.bottom, 4.5)
      .padding([.top, .leading, .trailing], 3)
  }
}
//let _ = print("selStr: \(selStr)"); let _ = print("sels: \(sels.count)")

// ???: xx
// !!!: xx
// MARK:
// TODO:
// FIXME:
// ???:
// !!!:
