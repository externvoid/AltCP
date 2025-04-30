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
  @Published var ticker: String = ""
  init() {}
  init(typ: Typ) {
    self.typ = typ
  }
  init(typ: Typ, limit: Int) {
    self.typ = typ
    self.limit = limit
  }
  init(typ: Typ, limit: Int, ticker: String) {
    self.typ = typ
    self.limit = limit
    self.ticker = ticker
  }
}
