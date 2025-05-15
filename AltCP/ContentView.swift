//  Created by Tanaka Hiroshi on 2024/10/01.
import NWer
import SwiftUI

struct ContentView: View {
  @AppStorage("foo") var selStr: String = "0000"
  var sels: String {
    get { selStr.components(separatedBy: ",").first ?? "0000" }
  }
  @State var codes: [[String]] = []
  @State var selection: String? = nil
  @EnvironmentObject var env: AppState
  var body: some View {
    soloCodePlot()
  }
  
  func soloCodePlot() -> some View {
    VStack(spacing: 0.0) {
      if env.typ == .all {
        let _ = print("selection@ContentView: \(selection ?? "Empty")")
        dwmPlot(selection ?? sels) // passed via onLongPressed
      } else {
        singlePlot()
      }
    }
    .task {
      print("codes.count@SinglePlot: \(codes.count)")
      if codes.isEmpty {
        do {
          codes = try await Networker.queryCodeTbl(
            DBPath.dbPath(1),
            DBPath.dbPath(2))
          print("ContentView: \(codes.count)")
        } catch {
          print("error@ContentView: \(error)")
        }
      }
    }
    .onChange(of: selection) { // unreachable
      //      selStr = selection
      print("onChange@ContentView: \(selection ?? "nil")")
    }
    .onChange(of: env.typ) { // unreachable
      print("onChange@ContentView: \(env.typ)")
    }
  }

  func singlePlot() -> some View {
    StockView(selected: sels, codes: $codes, selection: $selection)
      .modifier(TitleBarMnu2())
      .modifier(TitleBarBtn2())
      .navigationTitle(env.titleBar)
      .padding(.bottom, 4.5)
      .padding([.top, .leading, .trailing], 3)
      .onAppear {
        selection = sels
      }
  }
  func dwmPlot(_ txt: String) -> some View {
    ScrollView(.vertical) {
      LazyVGrid(columns: columns, spacing: 10) {
        ForEach([Typ.dy, Typ.wk, Typ.mn], id: \.id) {typ in
//      ForEach(Typ.allCases, id: \.id) {typ in
          StockView(selected: selection ?? "0000", typ: typ, codes: $codes,
                    selection: $selection)
            .frame(height: CHARTWIDTH*0.75)
            .padding(5)
        }
      }
    } // ScrollView
    .modifier(TitleBarMnu2())
    .modifier(TitleBarBtn2())
//    .modifier(TitleBarMnu(limit: $env.limit))
//    .modifier(TitleBarBtn(typ: $env.typ, dwm: $env.dwm))
    .navigationTitle(env.titleBar)
    .padding(.bottom, 4.5)
    .padding([.top, .leading, .trailing], 3)
  }
}
// ???: xx
// !!!: xx
// MARK: xx
// TODO: xx
// FIXME: xx
