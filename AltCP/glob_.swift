//
//  ext_.swift
//  AltCP
//
//  Created by Tanaka Hiroshi on 2024/10/01.
//


import Foundation

extension Date {
  //  private static var a: Int { 1 } // 奇妙な挙動に困った
  //  private static var b: Int = 1
  // error: extensions must not contain stored properties
  // var c: Int = 1
  public static let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone = NSTimeZone.system
    formatter.locale = Locale(identifier: "ja_JP")
    // formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
  }()
  // Date →String, print(Date().string()) // => 2023-05-24T22:54:57+0900
  public func string(format: String = "yyyy-MM-dd'T'HH:mm:ssZ") -> String {
    let formatter: DateFormatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.string(from: self)
  }

  // String → Date
  public init?(dateString: String, dateFormat: String = "yyyy/MM/dd") {
    Date.formatter.dateFormat = dateFormat
    guard let date = Date.formatter.date(from: dateString) else { return nil }
    self = date
  }
}
// https://stackoverflow.com/questions/31904396/swift-binary-search-for-standard-array

// Created 2024/11/10.
// MARK: binarySearch usage
// var r: Int
// r = ar.binarySearch { $0.date < "2024/06/29" } => "2024/07/01"
// r = ar.binarySearch { $0[0] < "3320" }

extension RandomAccessCollection {
  /// Finds such index N that predicate is true for all elements up to
  /// but not including the index N, and is false for all elements
  /// starting with index N.
  /// Behavior is undefined if there is no such N.
  func binarySearch(predicate: (Element) -> Bool) -> Index {
    var low = startIndex
    var high = endIndex
    while low != high {
      let mid = index(low, offsetBy: distance(from: low, to: high)/2)
      if predicate(self[mid]) {
        low = index(after: mid)
      } else {
        high = mid
      }
    }
    return low
  }
}

extension Double {
  var formatNumber: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 1
    formatter.minimumFractionDigits = 0  // 必要に応じて0を表示しない
    formatter.roundingMode = .halfUp

    let rounded = (self * 10).rounded() / 10
    return formatter.string(from: NSNumber(value: rounded))!
  }
}
// 使用例
// var str1 = 1.234.formatNumber  // "1.2"
// str1 = 2.04.formatNumber // 2
// str1 = 3000.0.formatNumber // 3,000



// print(Date(dateString: "2024-01-10") as Any)

//public extension Date {
//  private var formatter: DateFormatter {
//    let formatter = DateFormatter()
//    formatter.timeZone = NSTimeZone.system
//    formatter.locale = Locale(identifier: "en_US_POSIX")
//    formatter.calendar = Calendar(identifier: .gregorian)
//    return formatter
//  }
//  private static var formatter: DateFormatter {
//    let formatter = DateFormatter()
//    formatter.timeZone = NSTimeZone.system
//    formatter.locale = Locale(identifier: "en_US_POSIX")
//    formatter.calendar = Calendar(identifier: .gregorian)
//    return formatter
//  }
//  // Date→String
//  func string(format: String = "yyyy-MM-dd'T'HH:mm:ssZ") -> String {
//    let formatter: DateFormatter = DateFormatter()
//    formatter.timeZone = NSTimeZone.system
//    formatter.locale = Locale(identifier: "en_US_POSIX")
//    formatter.calendar = Calendar(identifier: .gregorian)
//    // 理由は不明だが、計算型プロパティは不可。clousureの即時呼出で値をセット
//    formatter.dateFormat = format
//    return formatter.string(from: self)
//  }
//
//  // String → Date, used at xtics, xtics2
//  init?(dateString: String, dateFormat: String = "yyyy/MM/dd") {
//    // Static member 'formatter' cannot be used on instance of type 'Date'
//    Date.formatter.dateFormat = dateFormat
//    guard let date = Date.formatter.date(from: dateString) else { return nil }
//    self = date
//  }
//}
extension Array {
  func revert<T>(ar: [T]) -> [T] {
    var ret: [T] = []
    for e in ar.reversed() {
      ret.append(e)
    }
    return ret
  }
}
// [新しいアプリを作るときによく使うSwift Extension集 - Qiita](https://qiita.com/WorldDownTown/items/cf59b0c70da9da61a875)
//Date().string(format: "yyyy/MM/dd") // 2017/02/26
//Date(dateString: "2016-02-26T10:17:30Z")  // Date
// reduceの使い方、into: 初期値、r: 戻値、e: iterated element
// heightを与えて..., e/quoteH * height, quote: 取引値、
// heightを与えず..., e - min /quoteH, quote: 取引値、
// quoteH = max - min

// 2025-04-18Fr
import SwiftUI
// Adaptive GridItem
let columns: [GridItem]
= [GridItem(.adaptive(minimum: CHARTWIDTH, maximum: .infinity), spacing: 5)]

//codes.countContentView: 3970

//["1711", "(株)ＳＤＳホールディングス", "東証STD", "時価総額2,190百万円", "【特色】省エネ施設の設計・施工で再建図る。太陽光発電事業は大型から自家消費型の施工販売へ転換", "建設業"]
//  [Swiftでキューを理解する #Swift - Qiita](https://qiita.com/katopan/items/987ae34ef6fe94782f81)
//  Created by Tanaka Hiroshi on 2025/04/13.
//


struct Queue<T: Equatable> {
  var ar: [T]
  var maxSize: Int// = 5

  mutating func append(_ element: T) {
    // Prevent appending duplicate elements.
    if let n = ar.firstIndex(of: element) {
      ar.remove(at: n)
    }
    // If the queue is at max size, remove the first element
    if ar.count == maxSize {
      ar.removeFirst()
    }
    // Append the new element
    ar.append(element)
  }

  mutating func removeFirst() -> T? {
    return ar.isEmpty ? nil : ar.removeFirst()
  }

  func peek() -> T? {
    return ar.first
  }

  var count: Int {
    return ar.count
  }

  var isEmpty: Bool {
    return ar.isEmpty
  }
}
//var queueOfAnimals = Queue(ar: ["🐺", "🐵", "🐑", "🐶", "🐍"], maxSize: 5)
//末尾に入れる
//queueOfAnimals.enqueue("🐯")
//先頭を取り除く
//queueOfAnimals.dequeue()

//🔹 === Global func and Constant ===
let CHARTWIDTH: Double = 400
let MAXSIZE: Int = 20
let CANNUMSMA: Int = 90
let CANNUMMID: Int = 120
let CANNUMLAR: Int = 150
// キューに変換する

func str2Que(_ str: String) -> Queue<String> {
  var queue = Queue<String>(ar: [], maxSize: MAXSIZE)
  if str.isEmpty { queue.append("0000"); return queue }
  str.components(separatedBy: ",")
    .map { $0.trimmingCharacters(in: .whitespaces) }
    .filter { !$0.isEmpty }
    .forEach { e in
      queue.append(e)
    }
//  if queue.count < MAXSIZE {
//    for _ in 0..<(MAXSIZE - queue.count) { queue.ar.append("0000") }
  if queue.isEmpty {
    queue.append("0000")
  } else if queue.count > MAXSIZE {
    for _ in 0..<(str.components(separatedBy: ",").count - MAXSIZE) {
      queue.ar.removeFirst()
    }
  }
  return queue
}
// makeLimitedCodesContaingStr
func makeLimitedCodesContaingStr(_ selStr: String) -> String {
  if selStr.components(separatedBy: ",").count > MAXSIZE {
    var br = selStr.components(separatedBy: ",")
    for _ in 0..<(br.count - MAXSIZE) {
      br.removeFirst()
    }
    return br.joined(separator: ",")
  } else {
    return selStr
  }
}
