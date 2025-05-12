import NWer
//  Created by Tanaka Hiroshi on 2024/10/01.
import SwiftUI

struct ContentView: View {
  @AppStorage("foo") var selStr: String = "0000"
  var sels: String {
    get { selStr.components(separatedBy: ",").first ?? "0000" }
  }
  @State var codes: [[String]] = []
  @EnvironmentObject var env: AppState
  var body: some View {
    soloCodePlot()
  }
  
  func soloCodePlot() -> some View {
    VStack(spacing: 0.0) {
      if env.typ == .all {
        let _ = print("env.ticker@ContentView: \(env.ticker.isEmpty ? "empty" : env.ticker)")
        dwmPlot(env.ticker)
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
    .onChange(of: env.ticker) { // unreachable
      //      selStr = env.ticker
      print("onChange@ContentView: \(env.ticker)")
    }
    .onChange(of: env.typ) { // unreachable
      print("onChange@ContentView: \(env.typ)")
    }
  }

  func singlePlot() -> some View {
    StockView(selected: sels, codes: $codes)
      .modifier(TitleBarMnu2())
      .modifier(TitleBarBtn2())
      .navigationTitle(env.titleBar)
//      .task {
//        print("codes.count@SinglePlot: \(codes.count)")
//        if codes.isEmpty {
//          do {
//            codes = try await Networker.queryCodeTbl(
//              DBPath.dbPath(1),
//              DBPath.dbPath(2))
//            print("ContentView: \(codes.count)")
//          } catch {
//            print("error@ContentView: \(error)")
//          }
//        }
//      }
      .padding(.bottom, 4.5)
      .padding([.top, .leading, .trailing], 3)
  }
  func dwmPlot(_ txt: String) -> some View {
    ScrollView(.vertical) {
      LazyVGrid(columns: columns, spacing: 10) {
        ForEach([Typ.dy, Typ.wk, Typ.mn], id: \.id) {typ in
//      ForEach(Typ.allCases, id: \.id) {typ in
          StockView(selected: txt.isEmpty ? sels : txt, typ: typ, codes: $codes)
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
//    .task {
//      print("codes.count@dwmPlot: \(codes.count)")
//      if codes.isEmpty {
//        do {
//          codes = try await Networker.queryCodeTbl(
//            DBPath.dbPath(1),
//            DBPath.dbPath(2))
//          print("ContentView: \(codes.count)")
//        } catch {
//          print("error@ContentView: \(error)")
//        }
//      }
//    }
    .padding(.bottom, 4.5)
    .padding([.top, .leading, .trailing], 3)
  }
}

/// - Description: chart wrapper
/// - Parameter selected: ticker code
struct StockView: View {
  @State var isShown: Bool = false
  @State var hoLoc: CGPoint = .zero
  @State var oldLoc: CGPoint = .zero

  @StateObject var c: VM
  @EnvironmentObject var env: AppState
  init(selected: String, codes: Binding<Array<Array<String>>>){
     _c = StateObject(wrappedValue: VM(ticker: selected))
     _codes = codes
   }
  init(selected: String, typ: Typ, codes: Binding<Array<Array<String>>>){
    _c = StateObject(wrappedValue: VM(ticker: selected, typ: typ))
    _codes = codes
  }
  @Binding var codes: [[String]]// = []
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
    .onChange(of: env.ticker) {
      c.ticker = env.ticker
      print("onChange: \(env.ticker): c.ar: \(c.ar.count)")
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

// MARK: extension
extension StockView {
  @ViewBuilder
  var btn: some View {
    Button(
      action: {
        isShown = true
      },
      label: {
        ZStack {
          Image(systemName: "plus.circle")
            .resizable()
            .frame(width: 30, height: 30)
            .foregroundStyle(
              Color(.green.opacity(0.4))
            )
            .symbolEffect(.bounce, value: isShown)
        }
      }
    )
    .buttonStyle(PlainButtonStyle())
    .popover(isPresented: $isShown) {
      ZStack {
        popUp
      }
      .frame(width: 300, height: 300)
    }
  }  // btn
  @ViewBuilder
  var popUp: some View {
    VStack {
      textBox(txt: $txt)
      ScrollViewReader { proxy in

        ScrollView {
          LazyVStack(spacing:0) {
            ForEach(0..<items.count, id: \.self) { number in
              Button(action: {
                scrollPosition = number
                c.ticker =
                  items[number].components(separatedBy: ":").first ?? ""
                env.ticker = c.ticker
                print("tapped \(scrollPosition!)")
                print("tapped \(items[number])")
                isShown = false
              }) {
                  Text(items[number])
                  .fontDesign(.monospaced)
                    .frame(width: 260, height: 20, alignment: .topLeading)
                    .lineLimit(1)
                    .foregroundColor(.blue)
              }
              .background(Color.black.opacity(0.7))
              .id(number)
            }  // For
            .scrollTargetLayout()  // report current pos.
          }
        }  // ScrollView
        .scrollPosition(id: $scrollPosition)
        .onAppear {
          proxy.scrollTo(scrollPosition, anchor: .leading)
        }
      }  // Reader
    }  // V
    .padding()
  }  // popUp
// MARK: textBox in popUp
    func textBox(txt: Binding<String>) -> some View {
    HStack {
      Spacer()
      TextField("code or name", text: txt).font(.title3)
        .onSubmit {
          print("press Enter: \(txt.wrappedValue)")
          if !items.isEmpty {
            // env.ticker =
            c.ticker =
            items[0].components(separatedBy: ":").first ?? ""
            env.ticker = c.ticker
          }
          isShown = false
        }
      Spacer()
      Button {
        self.txt = ""
      } label: {
        Image(systemName: "xmark.circle").resizable()
          .frame(width: 25, height: 25)
          .scaledToFit()
      }
    }
  }

  /// obtain the array of the detailed code related info
  /// - Parameter code
  /// - Returns: [code, name, market, capital, feat, category]
  // MARK: findInfo
  func findInfo(_ code: String) -> [String] {
    if let info = codes.first(where: { e in e[0] == code }) {
      return info//Array(info[0..<4])
    } else {
      let info: [String] = ["Not Found"]
      return info
    }
  }
  // MARK: findNext, not used
  func findNext(_ code: String) -> [String] {
    for i in codes.indices {
      if codes[i][0] == code {
        if i <= codes.count - 2 {
          return codes[i+1]
        } else {
          return codes[0]
        }
      }
    }
    return []
//    fatalError("fatal in findNext")
  }

  /// - Description: the index to ticker and company name.
  /// - Parameter scPos: the index of Array of Array, that is codes.
  /// - Returns: ticker and company name.
  // MARK: codeInfo, not used
  func codeInfo(_ scPos: Int?) -> String {
    if scPos != nil && codes.isEmpty == false {
      print(scPos!)
      return codes[scPos!][0] + codes[scPos!][1]
      //      return "Found"
    } else {
      return "Not Found"
    }
  }
}

#Preview {
  ContentView()
    .navigationTitle("ooPs")
    .frame(width: 420, height: 360*1)
    .padding([.top, .leading, .trailing], 5)
    .padding([.bottom], 7)
    .environmentObject(AppState())
}
// ???: xx
// !!!: xx
// MARK: xx
// TODO: xx
// FIXME: xx
