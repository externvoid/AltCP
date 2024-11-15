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
