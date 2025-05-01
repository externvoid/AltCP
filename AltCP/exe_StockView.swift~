//
//  exe_StockView.swift
//  AltCP
//
//  Created by Tanaka Hiroshi on 2025/04/30.
//

import SwiftUI
struct PopUp2: View {
  @Binding var txt: String
  @Binding var isShown: Bool
  @Binding var scrollPosition: Int?
  @EnvironmentObject var env: AppState2
  let items: [String]
//  var onTickerSelected: (String) -> Void

  var body: some View {
    VStack {
      textBox(txt: $txt)
      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack(spacing: 0) {
            ForEach(0..<items.count, id: \.self) { number in
              Button(action: {
                scrollPosition = number
                env.ticker = items[number].components(separatedBy: ":").first ?? ""
//                onTickerSelected(ticker)
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
            }
            .scrollTargetLayout()
          }
        }
        .scrollPosition(id: $scrollPosition)
        .onAppear {
          proxy.scrollTo(scrollPosition, anchor: .leading)
        }
      }
    }
    .padding()
  }

  func textBox(txt: Binding<String>) -> some View {
    HStack {
      Spacer()
      TextField("code or name", text: txt)
        .font(.title3)
        .padding(.horizontal, 5)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(5)
        .onSubmit {
          print("press Enter: \(txt.wrappedValue)")
          if !items.isEmpty {
            env.ticker =
            //            env.ticker =
            items[0].components(separatedBy: ":").first ?? ""
            //            selsStr = "0000"
            print("onSubmit \(env.ticker)")
          }
          isShown = false
        }
      Spacer()
      Button(action: {
        self.txt = ""
      }) {
        Image(systemName: "xmark.circle")
          .resizable()
          .scaledToFit()
          .frame(width: 15)
      }
    }
  }
}
