//
//
//  Created by Tanaka Hiroshi on 2024/10/01.
//
import Foundation

class AppState: ObservableObject {
  @Published var typ: Typ = .dy
  @Published var limit: Int = CANNUMSMA
  @Published var titleBar: String = ""
  init() {}
  init(_ typ: Typ) {
    self.typ = typ
  }
}
