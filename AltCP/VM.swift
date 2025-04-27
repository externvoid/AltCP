//  Created by Tanaka Hiroshi on 2024/10/01.

import Combine
//[【Xcode/Swift】APIエラー：App Transport Securityの解決方法 - iOS-Docs](https://ios-docs.dev/app-transport-security/)
// 📅2024/01/12Fr
import Foundation
import NWer

public typealias candle = (
  date: String, open: Double, high: Double, low: Double,
  close: Double, volume: Double
)
public typealias xtick = (date: Date?, norm: Int, st: Bool)
public enum Typ: Int { case dy = 0; case wk = 1; case mn = 2 }

// MARK: VM
@MainActor
public class VM: ObservableObject {
  @Published public var ar: [candle] = []
  var wk:[candle] = []
  var mn:[candle] = []
  var dy:[candle] = []
  var prevTicker: String = ""
  var prevTyp: Typ = .dy
  @Published var limit: Int = 90
  {
    didSet {
      switch typ {
        case .dy:
          ar = Array(dy.suffix(limit))
        case .wk:
          ar = Array(wk.suffix(limit))
        case .mn:
        ar = Array(mn.suffix(limit))
      }
    }
  }
  @Published public var ticker: String = ""
  {
    didSet {
      print("--- didSet ticker: \(ticker)---")
//      ticker = "0000"
      if ticker.isEmpty { ticker = "0000" }
      Task {
        if typ == .dy {
          do {
            dy = try await Networker.queryHist(
              ticker, DBPath.dbPath(0), DBPath.dbPath(2), -1)
          } catch {
            ticker = prevTicker
            print("Error at didSet ticker: \(error)")
          }
//          ar = dy
          ar = Array(dy.suffix(limit))
        } else if typ == .wk {
          dy = try! await Networker.queryHist(
            ticker, DBPath.dbPath(0), DBPath.dbPath(2), -1)
          wk = convertToWeeklyData(from: dy)
          ar = Array(wk.suffix(limit))
        } else if typ == .mn {
          dy = try! await Networker.queryHist(
            ticker, DBPath.dbPath(0), DBPath.dbPath(2), -1)
          mn = convertToMonthlyData(from: dy)
          ar = Array(mn.suffix(limit))
        }
      }
    }
  }
  @Published public var typ: Typ = .dy
  {
    didSet {
      print("--- didSet typ: \(typ)---")
      Task {
        if typ == .dy {
//          ar = dy
          ar = Array(dy.suffix(limit))
        } else if typ == .wk {
          wk = convertToWeeklyData(from: dy)
//          ar = wk
          ar = Array(wk.suffix(limit))
        } else if typ == .mn {
          mn = convertToMonthlyData(from: dy)
//          ar = mn
          ar = Array(mn.suffix(limit))
        }
      }
    }
  }
  let dateFormatter = Date.formatter
//  let dateFormatter = DateFormatter()
#if DEBUG
  public init(ar: [candle] = dummy, ticker: String = "0000") {
    print("N225")
    self.ar = ar
    self.ticker = ticker
  }

  public init() {
    print("--- init() ---")
  }
#endif
  public init(ticker: String) {
    self.ticker = ticker
    print("--- init(ticker:)@VM ticker: \(ticker) ---")
//    Task {
//      ar = try! await Networker.queryHist(
//        ticker, DBPath.dbPath(0), DBPath.dbPath(2))
//    }

  }

  public var max: Double {
    ar.reduce(into: -Double.infinity) { r, e in
      r = [e.1, e.2, e.3, e.4, r].max()!
    }
  }
  public var min: Double {
    ar.reduce(into: +Double.infinity) { r, e in
      r = [e.1, e.2, e.3, e.4, r].min()!
    }
  }
  public var vmax: Double {
    ar.reduce(into: -Double.infinity) { r, e in
      r = [e.5, r].max()!
    }
  }
  public var qheight: Double { max - min }  //quote axis hieght
  public var yticks: [Double] {
    var ret: [Double] = []
    let n = floor(log10(qheight))  // number of digits
    let npow: Double = pow(10, n)  // 1160.0, 1000.0
    let r: Double = qheight / npow  // 1.16
    var interval: Double = 0.0
    switch r {
    case 1.0..<3.0:
      interval = npow / 4.0  // 250.0
    case 3.0..<5.0:
      interval = npow
    case 5.0..<10.0:
      interval = npow * 2.0
    default:
      interval = npow
    }
    //    debugPrint("Candle: \(qheight)")
    //    debugPrint("Candle: \(npow)")
    let start: Double = Double(Int(min / interval) + 1) * interval
    var tick: Double = start
    while tick < max {
      ret.append(tick)
      tick += interval
    }
    return ret
  }
  // 月初を検出
  public var xticks: [xtick] {
    var ret: [xtick] = []
    var st: Bool = false
    var e_d = extractMonth(ar[0].date)
    for (i, e) in ar.enumerated() {
      if e_d != extractMonth(e.date) { st = true }
      ret.append((Date(dateString: e.date), i, st))
      st = false
      e_d = extractMonth(e.date)
    }
    // retをサーチして一つもtrueが無いと先頭をtrueに！
    if ret.map({ e in e.st }).allSatisfy({ $0 == false }) {
      ret[0].st = true
    }
    return ret
  }
  // MARK: - 日付文字列が月(Int)だけ取出し
  public func extractMonth(_ str: String) -> Int? {
    return Int(str.components(separatedBy: "/")[1])
  }
  // MARK: - 日付文字列が年(Int)だけ取出し
  public func extractYear(_ str: String) -> Int? {
    return Int(str.components(separatedBy: "/")[0])
  }
}  // end of class
