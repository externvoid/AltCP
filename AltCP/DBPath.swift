//
//  DBPath.swift
//  AltCP
//
//  Created by Tanaka Hiroshi on 2024/10/01.
//


enum DBPath {
  static func dbPath(_ num: Int) -> String {
//    let dbBase = "~/Library/Application Support/ChartPlot/"
    let dbBase = "/Users/tanaka/Library/Application Support/ChartPlot/"

//    let dbBase = "/Volumes/twsmb/newya/asset/"
//    let dbBase = "/Volumes/home/NASData/StockDB/"

    let dbPath0 = dbBase + "crawling.db"
    let dbPath1 = dbBase + "yatoday.db"
    let dbPath2 = dbBase + "n225Hist.db"
    switch num {
      case 1: return dbPath1
      case 2: return dbPath2
      default: return dbPath0
    }
  }
}
