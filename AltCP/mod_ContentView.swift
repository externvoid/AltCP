//  Created by Tanaka Hiroshi on 2024/11/23.
import SwiftUI

// MARK: ViewModifier 1
struct OnHover: ViewModifier {
  //  var hoLoc: CGPoint  // = .zero
  //  var oldLoc: CGPoint  // = .zero
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

// MARK: ViewModifier 2, see Function-Key Unicode Values
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-and-respond-to-key-press-events
struct OnKeyPress: ViewModifier {
  var c: VM // inout
  //  @Binding var c: VM  //
  let codes: [[String]]
  let off: Int = 100
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
        } else if keyEquivalent == Character(UnicodeScalar(NSUpArrowFunctionKey)!) {
          print("up pressed")
          Task {
            if pos >= codes.count - off {
              c.ticker = codes[pos + off - codes.count].first!
            } else {
              c.ticker = codes[pos + off].first!
            }
          }
          return .handled
        } else if keyEquivalent == Character(UnicodeScalar(NSDownArrowFunctionKey)!) {
          print("down pressed")
          Task {
            if pos <= off {
              c.ticker = codes[pos - off + codes.count].first!
            } else {
              c.ticker = codes[pos - off].first!
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

// MARK: ViewModifier 3
struct TitleBarBtn: ViewModifier {
  @Binding var typ: Typ
//  @State var isShown: Bool = false
//  @State var txt: String = ""
//  @State var limit: Int = 10
  func body(content: Content) -> some View {
    content
      .toolbar {
        HStack(spacing:0) {
          //          Spacer()

          Button(action: {
            debugPrint("Daily tapped")
            typ = .dy
          }) {
            if typ == .dy {
              Image(systemName: "d.square.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.red, .yellow)

            } else {
              Image(systemName: "d.square.fill")
            }
          }
          .disabled(typ == .dy)

          Button(action: {
            print("Weekly tapped")
            typ = .wk
          }) {
            if typ == .wk {
              Image(systemName: "w.square.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.blue, .pink)
            } else { // not trapped
              Image(systemName: "w.square.fill")
            }
          }
          .disabled(typ == .wk)

          Button(action: {
            print("Monthly selected")
            typ = .mn
          }) {
            if typ == .mn {
              Image(systemName: "m.square.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.red, .green)
            } else {
              Image(systemName: "m.square.fill")
            }
          }
          .disabled(typ == .mn)
        }
      } // toolbar
  }
}

// MARK: ViewModifier 4
struct TitleBarMnu: ViewModifier {
  @Binding var limit: Int
  @State var txt: String = "Input Num"
  @State var isShown: Bool = false
  let cnt1 = 90, cnt2 = 120, cnt3 = 150
  func body(content: Content) -> some View {
    content
      .toolbar { // toolbarTitleMenu
        ToolbarItem(placement: .primaryAction) {
          Menu("Num") {
            Button(action: {
              limit = cnt1
              print("1 tapped")
            }) {
              Text(String(cnt1))
              if limit == cnt1 {
                Image(systemName: "1.circle.fill")
                  .symbolRenderingMode(.palette)
                  .foregroundStyle(.red, .green)
              } else {
                Image(systemName: "1.circle.fill")
              }
            }
            Button(action: {
              limit = cnt2
              print("2 tapped")
            }) {
              Text(String(cnt2))
              if limit == cnt2 {
                Image(systemName: "2.circle.fill")
                  .symbolRenderingMode(.palette)
                  .foregroundStyle(.red, .yellow)
              } else {
                Image(systemName: "2.circle.fill")
              }
            }
            Button(action: {
              limit = cnt3
              print("3 tapped")
            }) {
              Text(String(cnt3))
              if limit == cnt3 {
                Image(systemName: "3.circle.fill")
                  .symbolRenderingMode(.palette)
                  .foregroundStyle(.blue, .pink)
              } else {
                Image(systemName: "3.circle.fill")
              }
            }
            /*
            Button(action: {
              isShown = true
              print("pressed")
            },label: {
              Image(systemName: "xmark.circle.fill")
            })
            .popover(isPresented: $isShown) {
              let _ = print("popover")
              VStack {
                Text("Enter a number")
                TextField("", text: $txt)
                  .focusable()
                Button("OK") {
                  limit = Int(txt) ?? 0
                  isShown = false
                }
              }
            }
            */
            //            TextEditor(text: $txt)
            //            Button("input Num") {
            //              NSPopover.defaultPlaceholder.show(relativeTo: .init(itemIdentifier: .init(rawValue: "inputNum")), of: nil, preferredEdge: .minYEdge)
            //            }
            //            TextField("input Num", text: $txt)
            //              .focusable()
          }
        } // toolbar
      }
  }

}
//[swift - SwiftUI Add TextField to Menu - Stack Overflow](https://stackoverflow.com/questions/74061120/swiftui-add-textfield-to-menu)
