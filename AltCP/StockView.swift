//  Created by Tanaka Hiroshi on 2025/05/15.
import SwiftUI

// MARK: StockView
/// - Description: chart wrapper
/// - Parameter selected: ticker code
struct StockView: View {
  @AppStorage("foo") var selStr: String = "0000,6952,9432,1301"
  var sels: Queue<String> { str2Que(selStr) }
  @State var isShown: Bool = false
  @State var hoLoc: CGPoint = .zero
  @State var oldLoc: CGPoint = .zero

  @StateObject var c: VM
  @EnvironmentObject var env: AppState; var codes: [[String]] { env.codes }
  @State var titleBar: String = ""
  // MARK: init
  init(selection: Binding<String?>, typ: Typ){
    _c = StateObject(wrappedValue: VM(ticker: selection.wrappedValue!,typ: typ))
    print("selected@StockView.init: \(selection.wrappedValue ?? "nil")")
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
  // MARK: body
  var body: some View {
    GeometryReader { geometry in
      let fsize = geometry.frame(in: .local).size
      if !c.ar.isEmpty {
        chart(fsize: fsize) // MARK: plot
      }
    }  // geo
    .onTapGesture {
      print("code@onTapGesture: \(c.ticker)"); env.titleBar = c.ticker
    }
    .onChange(of: c.ticker) {
      print("onChange: \(c.ticker): c.ar: \(c.ar.count)")
    }
    .onChange(of: env.typ) { c.typ = env.typ }
    .onChange(of: env.limit) { c.limit = env.limit }
    .onAppear {
//      c.ticker = sels.ar.first!
      print("onAppear@GeometryReader: \(c.ticker): c.ar: \(c.ar.count)")
    }
    .background(
      Color("chartBg").opacity(0.5), in: RoundedRectangle(cornerRadius: 5.0))
//    .padding([.bottom], 1.5) // eliminate focusable frame lack at bottom
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
/// - Description: zzz
/// - Parameter zz
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
  //  @Binding var hoLoc: CGPoint
  var hoLoc: CGPoint
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: hoLoc.x, y: rect.minY))
    path.addLine(to: CGPoint(x: hoLoc.x, y: rect.maxY))
    return path
  }
}
