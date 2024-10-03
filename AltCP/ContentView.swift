import NWer
//  Created by Tanaka Hiroshi on 2024/10/01.
import SwiftUI

struct ContentView: View {
  @State var sels: [String] = ["1301"]
  //  @State var vms: [VM] = [.init(ar: VM.dummy), .init(ar: VM.dummy)]
  var body: some View {
    VStack(spacing: 0.0) {
      ChartView3(selected: $sels[0])
    }
    .padding(.all, 3)
  }
}

/// - Description
/// - Parameter selected: ticker code
struct ChartView3: View {
  @EnvironmentObject var appState: AppState  // 無視
  @State var isShown: Bool = false
  @State var hoLoc: CGPoint = .zero
  @State var oldLoc: CGPoint = .zero
  //  lazy var c: VM = .init(ticker: selected) // @StateObject
  @State var c: VM = .init()  //ar: []) // @StateObject
  //  @State var c: VM = .init(ar: VM.dummy) // @StateObject
  //  @Binding var c: VM //= .init(ar: VM.dummy) // @StateObject
  @State var codes: [[String]] = []
  @State var scrollPosition: Int? = 0
  @State var txt: String = ""  // 検索key
  @Binding var selected: String
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
      //      let _ = print("fsize: \(fsize)")
      //      let hsize: CGSize = .init(width: fsize.width, height: fsize.height / 2)
      ZStack(alignment: .bottomTrailing) {
        //        VStack(spacing: 0.0) {
        body0(fsize: fsize)  //, hoLoc: $hoLoc)
//        btn
//          .padding([.bottom, .trailing], 3)
      }
      //      .onChange(of: selected) {
      //        c.ticker = selected
      //        print("onChange")
      //      }
      .onChange(of: c.ticker) {
        print("onChange")
        isLoading = true
        Task {
//          Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
//          }
//          try! await Task.sleep(for: .seconds(0.1))
          c.ar = try! await Networker.queryHist(
            c.ticker, DBPath.dbPath(0), DBPath.dbPath(2))
          isLoading = false
        }
      }
      .onAppear {
        print("onAppear")
        c.ticker = selected
        isLoading = true
        Task {
          c.ar = try! await Networker.queryHist(
            c.ticker, DBPath.dbPath(0), DBPath.dbPath(2))
          isLoading = false
        }
      }
      .task {
        if codes.isEmpty {
          codes = try! await Networker.queryCodeTbl(
            DBPath.dbPath(1),
            DBPath.dbPath(2))
        }
      }
      //      body0(geometry: geometry)
      //        .border(.yellow.opacity(0.3), width: 1)
    }  // geo
    .background(
      Color("chartBg").opacity(0.5), in: RoundedRectangle(cornerRadius: 5.0))
    //    .cornerRadius(5)
    //    .border(.yellow.opacity(0.3), width: 1)
    //        .padding(.all, 10)
    //    .background(Color.white.opacity(0.3))
  }  // body
}  // View
// MARK: body0
extension ChartView3 {
  @ViewBuilder
  func body0(fsize: CGSize) -> some View {
    //    let hsize: CGSize = .init(width: fsize.width, height: fsize.height / 2)
    ZStack(alignment: .bottomTrailing) {
      CursorLine(hoLoc: hoLoc)
        .stroke(Color.red.opacity(0.3), lineWidth: 1)
        .frame(width: fsize.width)
      chart(fsize: fsize)
      dateOHLCV(fsize: fsize)
      btn
        .padding([.bottom, .trailing], 3)

      //        .frame(alignment: .topLeading)
      //              .frame(width: geometry.size.width)
      //              .background { Rectangle().fill(.clear) }
    }  //   Z
    .modifier(OnHover(hoLoc: $hoLoc, oldLoc: $oldLoc, fsize: fsize))
    //    .overlay {
    //    }
    //      .background { Rectangle().fill(.red) }
  }  // body0
  /// - Description
  @ViewBuilder
  ///
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
            "d: \(d) v: \(v)\no: \(o) o: \(o) h: \(h) l: \(l)\nc: \(cl) ch: \(ch) %"  // fix wrong volume
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

// MARK: ViewModifier
struct OnHover: ViewModifier {
  @Binding var hoLoc: CGPoint  // = .zero
  @Binding var oldLoc: CGPoint  // = .zero
  var fsize: CGSize
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
        Color.gray
        popUp
      }
      .frame(width: 200, height: 300)
    }
  }  // btn
  @ViewBuilder
  var popUp: some View {
    VStack {
      textBox(txt: $txt)
      ScrollViewReader { proxy in

        ScrollView {
          LazyVStack {
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
                ZStack {
                  // ZStack(alignment: .leading) {
                  //                Circle()
                  //                  .stroke(Color.white, style: StrokeStyle(lineWidth: 3))
                  //                Text(number.formatted())
                  //                  Text(codes[number][0] + codes[number][1])
                  Text(items[number])
                    .frame(width: 160, height: 20, alignment: .leading)
                  //                  .frame(width: 200, height: 20, alignment: .leading)
                }  //.frame(width: 200, height: 20, alignment: .leading)
              }
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
  func findInfo(_ code: String) -> [String] {
    if let info = codes.first(where: { e in e[0] == code }) {
      return info//Array(info[0..<4])
    } else {
      let info: [String] = ["Not Found"]
      return info
    }
  }
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
    .frame(width: 320, height: 350)
    .padding([.top, .leading, .trailing], 5)
    .padding([.bottom], 7)
    .environmentObject(AppState())
}
