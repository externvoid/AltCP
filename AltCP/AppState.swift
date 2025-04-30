//
//
//  Created by Tanaka Hiroshi on 2024/10/01.
//
import Foundation

class AppState: ObservableObject {
  @Published var typ: Typ = .dy
  @Published var limit: Int = CANNUMSMA
  @Published var titleBar: String = ""
  @Published var dwm: Bool = true
  init() {}
  init(typ: Typ, limit: Int) {
    self.typ = typ
    self.limit = limit
  }
}

class AppState2: ObservableObject {
  @Published var ticker: String = ""
  init() {}
  init(ticker: String) {
    self.ticker = ticker
  }
}
