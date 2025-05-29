//  Created by Tanaka Hiroshi on 2024/10/01.
import NWer
import SwiftUI

struct ContentView: View {
  @AppStorage("foo") var selStr: String = "0000,6952,9432,1301,130A"
  var sels: Queue<String> { str2Que(selStr) }
  @EnvironmentObject var env: AppState
  var body: some View {
    if let _ = env.selection {
      soloCodePlot()
//      singlePlot(text)
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
    .modifier(TitleBarMnu2())
    .modifier(TitleBarBtn2())
    //    .modifier(TitleBarMnu(limit: $env.limit))
    //    .modifier(TitleBarBtn(typ: $env.typ))
    .navigationTitle(env.titleBar)
    .padding(.bottom, 4.5)
    .padding([.top, .leading, .trailing], 3)
  }
  // allCodesPlot
  //        ForEach(env.codes, id: \.self) {e in
  //          StockView(selection: .constant(e[0]), typ: env.typ)
  //            .onLongPressGesture {
  //              env.selection = e[0]
  private func singlePlot() -> some View {
    StockView(selection: $env.selection, typ: env.typ)
    //    StockView(selected: text, selection: $env.selection)
      .onLongPressGesture {
        env.selection = nil
      }
      .modifier(TitleBarMnu2())
      .modifier(TitleBarBtn2())
//      .modifier(TitleBarMnu(limit: $env.limit))
//      .modifier(TitleBarBtn(typ: $env.typ))
      .navigationTitle(env.titleBar)
      .padding(.bottom, 4.5)
      .padding([.top, .leading, .trailing], 3)
  }
  func soloCodePlot() -> some View {
    VStack(spacing: 0.0) {
      if env.typ == .all {
        let _ = print("selection@ContentView: \(env.selection ?? "Empty")")
        dwmPlot() // passed via onLongPressed
      } else {
        singlePlot()
      }
    }
    .onChange(of: env.selection) { // unreachable
      //      selStr = env.selection
      print("onChange@ContentView: \(env.selection ?? "nil")")
    }
    .onChange(of: env.typ) { // unreachable
      print("onChange@ContentView: \(env.typ)")
    }
  }

  func dwmPlot() -> some View {
    ScrollView(.vertical) {
      LazyVGrid(columns: columns, spacing: 10) {
        ForEach([Typ.dy, Typ.wk, Typ.mn], id: \.id) {typ in
          //      ForEach(Typ.allCases, id: \.id) {typ in
          StockView(selection: $env.selection, typ: typ)
          .frame(height: CHARTWIDTH*0.75)
          .padding(5)
        }
      }
    } // ScrollView
    .onLongPressGesture {
      print("LongPressGesture@dwmPlot")
      env.selection = nil
      env.typ = .dy
    }
    .modifier(TitleBarMnu2())
    .modifier(TitleBarBtn2())
    //    .modifier(TitleBarMnu(limit: $env.limit))
    //    .modifier(TitleBarBtn(typ: $env.typ, dwm: $env.dwm))
    .navigationTitle(env.titleBar)
    .padding(.bottom, 4.5)
    .padding([.top, .leading, .trailing], 3)
  }

//  func singlePlot() -> some View {
//    StockView(selected: sels, codes: $codes, selection: $env.selection)
//      .modifier(TitleBarMnu2())
//      .modifier(TitleBarBtn2())
//      .navigationTitle(env.titleBar)
//      .padding(.bottom, 4.5)
//      .padding([.top, .leading, .trailing], 3)
//      .onAppear {
//        env.selection = sels
//      }
//  }
}
//let _ = print("selStr: \(selStr)"); let _ = print("sels: \(sels.count)")
#Preview {
  ContentView()
    .navigationTitle("ooPs")
    .frame(width: 420, height: 360*1)
  //    .frame(width: 200, height: 200)
    .padding([.top, .leading, .trailing], 5)
    .padding([.bottom], 7)
    .environmentObject(AppState())
}
// ???: xx
// !!!: xx
// MARK:
// TODO:
// FIXME:
// ???:
// !!!:
