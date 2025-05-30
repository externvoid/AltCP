//  Created by Tanaka Hiroshi on 2024/10/01.
import Foundation
// MARK: 週足
extension VM {
  // 格納しているdateは週初め
  func convertToWeeklyData(from dailyData: [candle]) -> [candle] {
    var weeklyData: [candle] = []
    var tempWeekData: [candle] = []

    dateFormatter.dateFormat = "yyyy/MM/dd"
    let calendar = Calendar.current
    var currentWeekOfYear: Int? = nil

    for day in dailyData {
      let utcDate = dateFormatter.date(from: day.date)!
      let weekOfYear = calendar.component(.weekOfYear, from: utcDate)
      // 週番号が変わったら週データを確定する
      if currentWeekOfYear != nil && currentWeekOfYear != weekOfYear && !tempWeekData.isEmpty {

        let open = tempWeekData.first!.open
        let close = tempWeekData.last!.close
        let high = tempWeekData.map { $0.high }.max()!
        let low = tempWeekData.map { $0.low }.min()!
        let volume = tempWeekData.map { $0.volume }.reduce(0, +)
        let weekDate = tempWeekData.first!.date

        weeklyData.append((date: weekDate, open: open, high: high, low: low, close: close, volume: volume))
        tempWeekData.removeAll()
      }
      currentWeekOfYear = weekOfYear
      tempWeekData.append(day)
    }

    // 残った最後の週も追加
    if !tempWeekData.isEmpty {
      let open = tempWeekData.first!.open
      let close = tempWeekData.last!.close
      let high = tempWeekData.map { $0.high }.max()!
      let low = tempWeekData.map { $0.low }.min()!
      let volume = tempWeekData.map { $0.volume }.reduce(0, +)
      let weekDate = tempWeekData.first!.date

      weeklyData.append((date: weekDate, open: open, high: high, low: low, close: close, volume: volume))
    }

    return weeklyData
  }
  // MARK: 月足
  func convertToMonthlyData(from dailyData: [candle]) -> [candle] {
    dateFormatter.dateFormat = "yyyy/MM/dd"

    var monthlyData: [candle] = []
    var tempMonthData: [candle] = []
    let calendar = Calendar.current

    for day in dailyData {
      let utcDate = dateFormatter.date(from: day.date)!
      let dayMonth = calendar.component(.month, from: utcDate)
      // let year = calendar.component(.year, from: date)
      // let monthKey = (year, dayMonth)

      if let firstDate = tempMonthData.first,
         let firstDateObj = dateFormatter.date(from: firstDate.date),
         calendar.component(.month, from: firstDateObj) != dayMonth {
        // 月が変わったら月データを確定
        let open = tempMonthData.first!.open
        let close = tempMonthData.last!.close
        let high = tempMonthData.map { $0.high }.max()!
        let low = tempMonthData.map { $0.low }.min()!
        let volume = tempMonthData.map { $0.volume }.reduce(0, +)
        let monthDate = tempMonthData.first!.date

        monthlyData.append((date: monthDate, open: open, high: high, low: low, close: close, volume: volume))
        tempMonthData.removeAll()
      }

      tempMonthData.append(day)
    }

    // 残った最後の月も追加
    if !tempMonthData.isEmpty {
      let open = tempMonthData.first!.open
      let close = tempMonthData.last!.close
      let high = tempMonthData.map { $0.high }.max()!
      let low = tempMonthData.map { $0.low }.min()!
      let volume = tempMonthData.map { $0.volume }.reduce(0, +)
      let monthDate = tempMonthData.first!.date

      monthlyData.append((date: monthDate, open: open, high: high, low: low, close: close, volume: volume))
    }

    return monthlyData
  }
}

#if DEBUG
extension VM {
  public static let dummy: [candle] = [
    // 0        , 1   , 2   , 3   , 4   , 5
    ("2015/4/27", 20063, 20069, 19909, 19983, 187004),
    ("2015/4/28", 20068, 20133, 20031, 20058, 208721),
    ("2015/4/30", 19847, 19852, 19502, 19520, 271949),
    ("2015/5/1", 19510, 19549, 19399, 19531, 223184),
    ("2015/5/7", 19356, 19461, 19257, 19291, 236567),
    ("2015/5/8", 19315, 19458, 19302, 19379, 256526),
    ("2015/5/11", 19637, 19679, 19586, 19620, 289377),
    ("2015/5/12", 19608, 19626, 19467, 19624, 273127),
    ("2015/5/13", 19568, 19791, 19494, 19764, 279159),
    ("2015/5/14", 19661, 19717, 19546, 19570, 257484),
    ("2015/5/15", 19693, 19750, 19633, 19732, 254872),
    ("2015/5/18", 19766, 19890, 19741, 19890, 276495),
    ("2015/5/19", 19977, 20087, 19946, 20026, 258423),
    ("2015/5/20", 20175, 20278, 20148, 20196, 257091),
    ("2015/5/21", 20215, 20320, 20175, 20202, 252498),
    ("2015/5/22", 20208, 20278, 20130, 20264, 207480),
    ("2015/5/25", 20331, 20417, 20318, 20413, 205248),
  ]
  public static let dummy2: [candle] = [
    ("1987/9/5", 25355, 25355, 25355, 25355, 42972),
    ("1987/9/7", 25004, 25004, 25004, 25004, 37928),
    ("1987/9/8", 25204, 25204, 25204, 25204, 54604),
    ("1987/9/9", 24937, 24937, 24937, 24937, 62002),
    ("1987/9/10", 24795, 24795, 24795, 24795, 56583),
    ("1987/9/11", 24828, 24828, 24828, 24828, 86229),
    ("1987/9/14", 24954, 24954, 24954, 24954, 75032),
    ("1987/9/16", 24967, 24967, 24967, 24967, 82164),
    ("1987/9/17", 24855, 24855, 24855, 24855, 120292),
    ("1987/9/18", 24844, 24844, 24844, 24844, 160561),
    ("1987/9/21", 24912, 24912, 24912, 24912, 91207),
    ("1987/9/22", 24866, 24866, 24866, 24866, 127891),
    ("1987/9/24", 24944, 24944, 24944, 24944, 152886),
    ("1987/9/25", 25095, 25095, 25095, 25095, 94594),
    ("1987/9/26", 25512, 25512, 25512, 25512, 145413),
    ("1987/9/28", 25837, 25837, 25837, 25837, 150412),
    ("1987/9/29", 25998, 25998, 25998, 25998, 117722),
    ("1987/9/30", 26010, 26010, 26010, 26010, 128074),
    ("1987/10/1", 25721, 25721, 25721, 25721, 146229),
    ("1987/10/2", 25862, 25862, 25862, 25862, 83769),
    ("1987/10/3", 26006, 26006, 26006, 26006, 57241),
    ("1987/10/5", 26018, 26018, 26018, 26018, 78606),
    ("1987/10/6", 26088, 26088, 26088, 26088, 114217),
    ("1987/10/7", 25952, 25952, 25952, 25952, 110088),
    ("1987/10/8", 26286, 26286, 26286, 26286, 167081),
    ("1987/10/9", 26338, 26338, 26338, 26338, 150361),
    ("1987/10/12", 26284, 26284, 26284, 26284, 66232),
    ("1987/10/13", 26400, 26400, 26400, 26400, 133672),
    ("1987/10/14", 26646, 26646, 26646, 26646, 140180),
    ("1987/10/15", 26428, 26428, 26428, 26428, 95289),
    ("1987/10/16", 26366, 26366, 26366, 26366, 76785),
  ]

}
#endif
