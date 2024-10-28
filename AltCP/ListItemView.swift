//  Created by Tanaka Hiroshi on 2024/10/08.
import SwiftUI

// MARK: ListItemView
struct ListItemView: View {
  @ObservedObject var c: VM
  @Binding var isShown: Bool
  var n: Int
  var title: String
  var body: some View {
    Button {
      print("\(n) Pressed!")
      print("\(title) Pressed!")
      c.ticker = title.components(separatedBy: ":").first ?? ""
      isShown = false
    } label: {
      HStack {
        Text(title).foregroundStyle(.blue)
        Spacer()
      }
      .padding([.leading], 5)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    // ButtonStyleでタップ中のスタイルを指定
    .buttonStyle(ListItemButtonStyle())
  }
  func title2code(_ title: String) -> String {
    let prefix = String(title.prefix(4))
    let reg = try! Regex("^[a-zA-Z0-9]+$")
    if prefix.contains(reg) {
      return prefix
    } else {
      return ""
    }
  }  //  先頭4文字取り出してTickerなら値をセット
}
// 🔹ボタンスタイルを使って押下時にボタンを変化させる。Gestureは不要！
/// Listで押下時の背景色を変える場合に使うButtonStyle
protocol ListButtonStyle: ButtonStyle {
  /// 通常の背景色
  var backgroundColor: Color { get }
  /// 押下時の背景色
  var pressedBackgroundColor: Color { get }
  /// 背景色を取得する
  /// - Parameter isPressed: 押下時かどうか
  /// - Returns: Color
  func backgroundColor(isPressed: Bool) -> Color
}

extension ListButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .background(backgroundColor(isPressed: configuration.isPressed))
  }

  func backgroundColor(isPressed: Bool) -> Color {
    return isPressed ? pressedBackgroundColor : backgroundColor
  }
}

struct ListItemButtonStyle: ListButtonStyle {
  var backgroundColor: Color = .init(
    red: 245 / 255, green: 245 / 255, blue: 245 / 255)
  var pressedBackgroundColor: Color = .init(
    red: 255 / 255, green: 192 / 255, blue: 203 / 255)
}
