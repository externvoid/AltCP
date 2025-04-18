//  Created by Tanaka Hiroshi on 2024/10/08.
import SwiftUI

// MARK: CodeOrNameView
extension ChartView3 {
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
        //        }
        //      .task { ar = await fetchCodeTbl(url) }
        //      .task { if ar.isEmpty { ar = await fetchCodeTbl(url) } }
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

//struct ContentView0: View {  // for playground
//  //  @State var txt: String = ""
//  @State var code: String = ""
//  @StateObject var c: VM = .init()  // Candle is in Sources
//  var body: some View {
//    popUp2
//  }
//}
#Preview {
  @Previewable @State var sels: String = "0000"
  VStack(spacing: 0.0) {
    ChartView3(selected: sels, codes: .constant([["0000"]]))
      .frame(width: 400 , height: 260)
    //      ChartView3(selected: $sels[0])
  }
  .padding(.all, 3)
}
