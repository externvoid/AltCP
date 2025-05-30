//  Created by Tanaka Hiroshi on 2024/10/01.
import Foundation
import NWer

class AppState: ObservableObject {
  @Published var typ: Typ = .dy
  @Published var limit: Int = CANNUMSMA
  @Published var titleBar: String = "browse history"
  @Published var codes: [[String]] = []
  @Published var selection: String? = nil
  @Published var mode: Mode = .full
  init() {
    do {
      print("QuerryCodeTbl")
      codes = try Task.sync {
        try await Networker.queryCodeTbl(
          DBPath.dbPath(1), DBPath.dbPath(2))
      }
    } catch {
      print("error: \(error)")
    }
  }
}
