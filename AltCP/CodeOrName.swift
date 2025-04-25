//  Created by Tanaka Hiroshi on 2024/10/08.
import SwiftUI

// MARK: CodeOrNameView
extension StockView {
  // MARK: - codeOrNameView
  var popUp2: some View {

    VStack {
      textBox2(txt: $txt)
      LazyVStack {
        //        Section(header: textBox2(txt: $txt)) {
        ForEach(0..<items.count, id: \.self) { n in
          ListItemView(c: c, isShown: $isShown, n: n, title: items[n])
            .listRowInsets(.init())
        }
      }
    }
//    .listStyle(.plain)
//    .navigationTitle("ListView")
    .padding()
    .frame(width: 300, height: 300)

  } // some View
  // MARK: textBox
  func textBox2(txt: Binding<String>) -> some View {
    HStack {
      Spacer()
      TextField("code or name", text: txt).font(.title)
      Spacer()
      Button {
        self.txt = ""
      } label: {
        Image(systemName: "xmark.circle").resizable()
          .scaledToFit().frame(width: 15)
      }
    }
  }
} // extention
