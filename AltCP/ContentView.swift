import NWer
//  Created by Tanaka Hiroshi on 2024/10/01.
import SwiftUI

struct ContentView: View {
  @AppStorage("foo") var sels: String = "0000"
//  @State var sels: [String] = ["1301"]
  //  @State var vms: [VM] = [.init(ar: VM.dummy), .init(ar: VM.dummy)]
  var body: some View {
    VStack(spacing: 0.0) {
      ChartView3(selected: sels)
//      ChartView3(selected: $sels[0])
    }
    .padding(.all, 3)
  }
}

/// - Description
/// - Parameter selected: ticker code
struct ChartView3: View {
//  @EnvironmentObject var appState: AppState  // 無視
  @State var isShown: Bool = false
  @State var hoLoc: CGPoint = .zero
  @State var oldLoc: CGPoint = .zero

  @StateObject var c: VM
   init(selected: String) {
     _c = StateObject(wrappedValue: VM(ticker: selected))
   }
  @State var codes: [[String]] = []
  @State var scrollPosition: Int? = 0
  @State var txt: String = ""  // 検索key
  @State var isLoading: Bool = false
  var allItems: [String] {  // code, company, category
    codes.map { e in e[0] + ": " + e[1] + ": " + e[2] }
    //    codes.map { e in (e[0] + ": " + e[1] + ": " + e[2]).trimmingCharacters(in: .whitespaces) }
  }
  var items: [String] {
    txt.isEmpty ? allItems : Array(allItems.filter { $0.contains(txt) })
  }
  // MARK: body
  var body: some View {
    GeometryReader { geometry in
      let fsize = geometry.frame(in: .local).size
      if !c.ar.isEmpty {
        plot(fsize: fsize)  //, hoLoc: $hoLoc)
      }
    }  // geo
    .onChange(of: c.ticker) {
      print("onChange: \(c.ticker): c.ar: \(c.ar.count)")
//      Task {
//        c.ar = try! await Networker.queryHist(
//          c.ticker, DBPath.dbPath(0), DBPath.dbPath(2))
//      }
      UserDefaults.standard.set(c.ticker, forKey: "foo")
    }
    .onAppear {
      print("onAppear@GeometryReader: \(c.ticker): c.ar: \(c.ar.count)")
//      c.ticker = selected
    }
    .task {
      print("task: \(codes.count)")
      if codes.isEmpty {
        codes = try! await Networker.queryCodeTbl(
          DBPath.dbPath(1),
          DBPath.dbPath(2))
        print("task: \(codes.count)")
      }
    }
    .background(
      Color("chartBg").opacity(0.5), in: RoundedRectangle(cornerRadius: 5.0))
  }  // body
}  // View
extension ChartView3 {
// MARK: plot
  func plot(fsize: CGSize) -> some View {
    ZStack(alignment: .bottomTrailing) {
      CursorLine(hoLoc: hoLoc)
        .stroke(Color.red.opacity(0.3), lineWidth: 1)
        .frame(width: fsize.width)
      chart(fsize: fsize)
        .modifier(OnKeyPress(c: c, codes: codes))
      dateOHLCV(fsize: fsize)
      btn
        .padding([.bottom, .trailing], 3)
    }  //   Z
    .modifier(OnHover(hoLoc: $hoLoc, oldLoc: $oldLoc, fsize: fsize))
  }  // plot
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
          let v = Int(c.ar[i].volume)
          let d = c.ar[i].date
          let o = Int(c.ar[i].open)
          let h = Int(c.ar[i].high)
          let l = Int(c.ar[i].low)
          let cl = Int(c.ar[i].close)
          var ch = 0.0
          if i != 0 {
            ch = (c.ar[i].close - c.ar[i - 1].close) / c.ar[i - 1].close * 100.0
            // round variable of Double ch into
            ch = Double(String(format: "%.2f", ch))!
          }
          return
            "d: \(d) v: \(v) ch: \(ch) %\no: \(o) h: \(h) l: \(l) c: \(cl)"
          // fix wrong volume
        } else {
          return ""
        }
      }
      Spacer()
      HStack {
        //        Text("hoLoc.x: \(hoLoc.x)")
        Text(str)
          //        Text("d: \(d) v: \(v)")  // fix wrong volume
          .font(.system(size: 9.5, design: .monospaced))
          .foregroundColor(.yellow.opacity(0.6))
          .offset(y: -12)
        Spacer()
      }
      //          .offset(x: -fsize.width + 45, y: -fsize.height + 28)
      //          .border(.green.opacity(0.6), width: 1)
      //        chart(fsize: hsize)
      //          .border(.orange.opacity(0.6), width: 1)
    }
  }  // dateOHLCV
}

// MARK: ViewModifier 1
struct OnHover: ViewModifier {
  @Binding var hoLoc: CGPoint  // = .zero
  @Binding var oldLoc: CGPoint  // = .zero
  let fsize: CGSize
  func body(content: Content) -> some View {
    content.onContinuousHover { isHovered in
      switch isHovered {
      case .active(let loc):
        hoLoc = loc
        oldLoc = loc
      //        print("loc: \(loc)")
      case .ended:
        if oldLoc.x < fsize.width / 2.0 {
          hoLoc = .zero
        } else {
          hoLoc = CGPoint(x: fsize.width, y: 0.0)
        }
      }
    }
  }
}
// MARK: ViewModifier 2
struct OnKeyPress: ViewModifier {
  var c: VM
//  @Binding var c: VM  //
  let codes: [[String]]
  func body(content: Content) -> some View {
    content
      .focusable()
      .onKeyPress { press in
        // 押されたキーが矢印キーかどうかを判定
        let keyEquivalent = press.characters.first!
        let pos = codes.binarySearch { $0[0] < c.ticker }
        if keyEquivalent == Character(UnicodeScalar(NSRightArrowFunctionKey)!) {
          print("right pressed")
          Task {
            if pos == codes.count - 1 {
              c.ticker = codes.first!.first!
            } else {
              c.ticker = codes[pos + 1].first!
            }
          }
          return .handled
        } else if keyEquivalent == Character(UnicodeScalar(NSLeftArrowFunctionKey)!) {
          print("left pressed")
          Task {
            if pos == 0 {
              c.ticker = codes.last!.first!
            } else {
              c.ticker = codes[pos - 1].first!
            }
          }
          return .handled
        }
        print(press.characters)
        return .handled
      }
  }
}


// MARK: Shape
struct CursorLine: Shape {
  //  @Binding var hoLoc: CGPoint
  var hoLoc: CGPoint
  func path(in rect: CGRect) -> Path {
    var path = Path()
    //    print("rect.minY: \(rect.minY)")
    //    print("rect.maxY: \(rect.maxY )")
    //    print("hoLoc: \(hoLoc)")
    path.move(to: CGPoint(x: hoLoc.x, y: rect.minY))
    path.addLine(to: CGPoint(x: hoLoc.x, y: rect.maxY))
    return path
  }
}

// MARK: extension
extension ChartView3 {
  @ViewBuilder
  var btn: some View {
    Button(
      action: {
        isShown = true
      },
      label: {
        ZStack {
          //        Color(nsColor: .windowBackgroundColor)
          //          .frame(width: 60, height: 60)
          Image(systemName: "plus.circle")
            .resizable()
            .frame(width: 30, height: 30)
            //            .imageScale(.large)
            //            .foregroundStyle(.tint)
            .foregroundStyle(
              Color(red: 0.1, green: 0.1, blue: 0.1, opacity: 0.3)
            )
            .symbolEffect(.bounce, value: isShown)
        }
      }
    )
    .buttonStyle(PlainButtonStyle())
    .popover(isPresented: $isShown) {
      ZStack {
//        Color.white.opacity(0.5)
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
            //            ForEach(0..<1000, id: \.self) { number in
            ForEach(0..<items.count, id: \.self) { number in
              Button(action: {
                scrollPosition = number
                //                                selected =
                c.ticker =
                  items[number].components(separatedBy: ":").first ?? ""
                print("tapped \(scrollPosition!)")
                print("tapped \(items[number])")
                isShown = false
                //                isLoading = true
              }) {
//                VStack(spacing:0) {
                  Text(items[number])
                  .fontDesign(.monospaced)
                    .frame(width: 260, height: 20, alignment: .topLeading)
                    .lineLimit(1)
//                    .allowsTightening(true)
//                    .minimumScaleFactor(0.9)
//                    .truncationMode(.tail)
//                    .padding(.leading, 10)
                    .foregroundColor(.blue)
//                    .frame(alignment: .leading)
//                } //.frame(width: 200, height: 20, alignment: .leading)
              }
//              .buttonStyle(PlainButtonStyle())
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
//  func textBox() -> some View { // arg txtは必要?
    func textBox(txt: Binding<String>) -> some View {
    HStack {
      Spacer()
      TextField("code or name", text: txt).font(.title3)
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
  // MARK: findNext
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

  /// <#Description#>
  /// - Parameter scPos: <#scPos description#>
  /// - Returns: <#description#>
  // MARK: codeInfo
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
    .frame(width: 400, height: 260)
//    .frame(width: 200, height: 200)
    .padding([.top, .leading, .trailing], 5)
    .padding([.bottom], 7)
    .environmentObject(AppState())
}
