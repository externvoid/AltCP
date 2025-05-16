//  Created by Tanaka Hiroshi on 2025/05/15.
import SwiftUI

// MARK: btn, popUp, textBox extension
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
                let t = items[number].components(separatedBy: ":").first ?? ""
                if let a = makeSelStr(sels.ar, t) { selStr = a }
                if let _ = env.selection { c.ticker = t }
                // selStr += "," + t
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
        .onSubmit {
          print("press Enter: \(txt.wrappedValue)")
          if !items.isEmpty {
            let t = items[0].components(separatedBy: ":").first ?? ""
            if env.selection == nil {
              if let a = makeSelStr(sels.ar, t) {
                selStr = a
              }
//              selStr += "," + t
            } else {
              c.ticker = t
            }
          }
//            c.ticker =
//            selStr += "," + (items[0].components(separatedBy: ":").first ?? "")
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
// MARK: Helper function.
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

  /// - Description: the index to ticker and company name.
  /// - Parameter scPos: the index of Array of Array, that is codes.
  /// - Returns: ticker and company name.
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

  // MARK: makeSelStr
  func makeSelStr(_ ar: [String], _ choice: String) -> String? {
    let selStr: String
    var br: [String] = Array(ar)
    let t = ar.joined(separator: ",")
    if !t.contains(choice) {  // 重複チェック
      if ar.count >= MAXSIZE {
        br.remove(at: 0)
        selStr = br.joined(separator: ",") + "," + choice
      } else {
        selStr = t + "," + choice
      }
      UserDefaults.standard.set(selStr, forKey: "foo")
      return selStr
    }
    return nil
  }
}

