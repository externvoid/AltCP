//import NWer
//  Created by Tanaka Hiroshi on 2025/05/15.
import SwiftUI

/// - Description: chart wrapper
/// - Parameter selected: ticker code
struct StockView: View {
  @State var isShown: Bool = false
  @State var hoLoc: CGPoint = .zero
  @State var oldLoc: CGPoint = .zero

  @StateObject var c: VM
  @EnvironmentObject var env: AppState

  @Binding var codes: [[String]]// = []
  @Binding var selection: String?
  init(selected: String, codes: Binding<Array<Array<String>>>,
       selection: Binding<String?>) {
    _c = StateObject(wrappedValue: VM(ticker: selection.wrappedValue ?? selected))
//    _c = StateObject(wrappedValue: VM(ticker: selected))
    _codes = codes
    _selection = selection
  }
  init(selected: String, typ: Typ, codes: Binding<Array<Array<String>>>,
       selection: Binding<String?>) {
    _c = StateObject(wrappedValue: VM(ticker: selection.wrappedValue ?? selected, typ: typ))
    _codes = codes
    _selection = selection
//    _selection = .constant(selected)
  }

  @State var scrollPosition: Int? = 0
  @State var txt: String = ""  // 検索key
  @State var isLoading: Bool = false
  var allItems: [String] {  // code, company, category
    codes.map { e in e[0] + ": " + e[1] + ": " + e[2] }
  }
  var items: [String] {
    txt.isEmpty ? allItems : Array(allItems.filter { $0.contains(txt) })
  }
  // MARK: body: StockView
  var body: some View {
//    let _ = env.typ = typ
    GeometryReader { geometry in
      let fsize = geometry.frame(in: .local).size
      if !c.ar.isEmpty {
        chart(fsize: fsize) // MARK: chart
      }
    }  // geo
    .onChange(of: c.ticker) {
      print("onChange@StockView: \(c.ticker): c.ar: \(c.ar.count)")
      UserDefaults.standard.set(c.ticker, forKey: "foo")
    }
    .onChange(of: env.typ) {
      c.typ = env.typ
      print("onChange: \(c.typ): c.ar: \(c.ar.count)")
    }
    .onChange(of: env.limit) {
      c.limit = env.limit
      print("onChange: \(c.limit): c.ar: \(c.ar.count)")
    }
    .onChange(of: selection) {
      c.ticker = selection! // passed via popUp
      print("onChange: \(selection ?? "nil"): c.ar: \(c.ar.count)")
      UserDefaults.standard.set(c.ticker, forKey: "foo")
    }
    .onAppear {
      print("onAppear@GeometryReader: \(c.ticker): c.ar: \(c.ar.count)")
      if env.typ != .all {
        c.typ = env.typ
        c.limit = env.limit
      }
      print("c.typ@onAppear: \(c.typ)")
    }
    .background(
      Color("chartBg").opacity(0.5), in: RoundedRectangle(cornerRadius: 5.0))
  }  // body
}  // View

extension StockView {
// MARK: chart
  func chart(fsize: CGSize) -> some View {
    ZStack(alignment: .bottomTrailing) {
      CursorLine(hoLoc: hoLoc)
        .stroke(Color.red.opacity(0.3), lineWidth: 1)
        .frame(width: fsize.width)
      candle(fsize: fsize)
        .modifier(OnKeyPress(c: c, codes: codes))
      dateOHLCV(fsize: fsize)
      btn
        .padding([.bottom, .trailing], 3)
    }  //   Z
    .modifier(OnHover(hoLoc: $hoLoc, oldLoc: $oldLoc, fsize: fsize))
  }  // chart
// - Description
// MARK: dateOHLCV
  func dateOHLCV(fsize: CGSize) -> some View {
    VStack(spacing: 0.0) {
      var i: Int {
        let cnt = c.ar.count
        let n = Int(hoLoc.x / fsize.width * Double(cnt))
        return n >= cnt ? cnt - 1 : n
      }
      var str: String {
        if !c.ar.isEmpty {
          let v = c.ar[i].volume.formatNumber
          let d = c.ar[i].date
          let o = c.ar[i].open.formatNumber
          let h = c.ar[i].high.formatNumber
          let l = c.ar[i].low.formatNumber
          let cl = c.ar[i].close.formatNumber
          var ch = 0.0
          if i != 0 {
            ch = (c.ar[i].close - c.ar[i - 1].close) / c.ar[i - 1].close * 100.0
          }
          return
            """
            d: \(d) v: \(v) ch: \(String(format: "%5.2f", ch))%
            o: \(o) h: \(h) l: \(l) c: \(cl)
            """
          // fix wrong volume, not amended using adj rate
        } else {
          return ""
        }
      }
      Spacer()
      HStack {
        Text(str)
          .font(.system(size: 10.5, design: .monospaced))
          .foregroundColor(.yellow.opacity(0.6))
          .offset(y: -12)
        Spacer()
      }
    }
  }  // dateOHLCV
}

// MARK: Shape
struct CursorLine: Shape {
  var hoLoc: CGPoint
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: hoLoc.x, y: rect.minY))
    path.addLine(to: CGPoint(x: hoLoc.x, y: rect.maxY))
    return path
  }
}
// ???: xx
// !!!: xx
// MARK: xx
// TODO: xx
// FIXME: xx
