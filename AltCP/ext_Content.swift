//  Created by Tanaka Hiroshi on 2024/10/01.
//  Created by Tanaka Hiroshi on 2024/09/26.
// MARK: candle
import SwiftUI

extension StockView {
  @ViewBuilder
  func candle(fsize: CGSize) -> some View {
//    let fsize: CGSize = geometry.size
    ZStack(alignment: .bottom) {
      VStack(spacing: 0.0) {//, content: <#T##() -> View#>) {
        // 1
        Canvas { ctx, size in  // size: 描画エリア、ar: 正規化取引値(0 - 1.0)
          candlestick(ctx, size)
          gridlines(ctx, size)
        }
        .frame(width: fsize.width, height: fsize.height * 3.0 / 4.0)
        // 2
        Canvas { ctx, size in  // Volume
          volumes(ctx, size)
        }
        .frame(width: fsize.width, height: fsize.height / 4.0)
//        .offset(y: -10)
      }  // 3
      Canvas { ctx, size in  // Date Caption
        xaxisDateTick(ctx, size)  //.border(.red)
      }.frame(width: fsize.width, height: 20, alignment: .bottom)
              .offset(y: 04)
    }  // Z
  }  // candle
/// - Description: Addressed missing Volume Graph
  func volumes(_ ctx: GraphicsContext, _ size: CGSize) {
    //  let h = size.height
    let width = size.width
    let h = size.height
    let n = c.ar.count
    let w = width / CGFloat(n)
    //    let mtx = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: -h / c.vmax, tx: 0.0, ty: h)
    //    let mtx0 = CGAffineTransform(scaleX: 1.0, y: -h / c.vmax)//, tx: 0.0, ty: h)
    let mtx0 = CGAffineTransform(translationX: 0.0, y: h)  //, tx: 0.0, ty: h)
    let mtx = mtx0.scaledBy(x: 1.0, y: -h)  // / c.vmax)
    var ps = Path()
    var pf = Path()  // 棒グラフ、塗り, 枠だけ

    for (i, e) in c.ar.enumerated() {
      let rect = CGRect(
        x: CGFloat(i) * w, y: 0.0, width: w, height: e.volume / c.vmax)
      assert(e.volume >= 0.0, "e.volume")
      pf.addRect(rect)
      ps.addRect(rect)
    }
    ctx.fill(pf.applying(mtx), with: .color(.blue.opacity(0.3)))
    ctx.stroke(ps.applying(mtx), with: .color(.red.opacity(0.3)))
  }
  // MARK: - draw 日付キャプション, xaxisDateTick
  /// - Parameter ctx: , size, xticks: (0,0) - (1,1)areaに描く出来高グラフのY座標
  func xaxisDateTick(_ ctx: GraphicsContext, _ size: CGSize) {
    if c.ar.isEmpty { return }
    let width = size.width
    let _ = size.height
    let n = c.ar.count
    let w = width / CGFloat(n)
    //    let mtx = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: -1.0, tx: 0.0, ty: h)
    switch c.typ {
      case .dy:
        for (i, e) in c.xticks.enumerated() {
          //    print(i, e.st)
          let point = CGPoint(x: CGFloat(i) * w, y: 0.0)
          if e.st == true {
            let strDate = Date.formatter.string(from: e.date!)  // => 2023/05/25
            let mo: Int = c.extractMonth(strDate)!
            var text: Text { Text("\(mo)月").font(.system(size: 11.5)) }
            ctx.draw(
              text,  // no affine trs frm
              at: point, anchor: UnitPoint(x: 0.0, y: 0.0))  //.bottomLeading)
          }
        }

      case .wk:
        for (i, e) in c.xticks.enumerated() {
          //    print(i, e.st)
          let point = CGPoint(x: CGFloat(i) * w, y: 0.0)
          if e.st == true {
            let strDate = Date.formatter.string(from: e.date!)  // => 2023/05/25
            let mo: Int = c.extractMonth(strDate)!
            if mo % 3 != 1 { continue }
            var text: Text { Text("\(mo)月").font(.system(size: 11.5)) }
            ctx.draw(
              text,  // no affine trs frm
              at: point, anchor: UnitPoint(x: 0.0, y: 0.0))  //.bottomLeading)
          }
        }
      case .mn:
        var notFound = true
        for (i, e) in c.xticks.enumerated() {
          //    print(i, e.st)
          let point = CGPoint(x: CGFloat(i) * w, y: 0.0)
          if e.st == true {
            let strDate = Date.formatter.string(from: e.date!)  // => 2023/05/25
            let mo: Int = c.extractMonth(strDate)!
            if mo % 12 != 1 { continue }
            let yr: Int = c.extractYear(strDate)!
            // FIXME: 要適当なキャプション
            if yr % 2 != 0 { continue }
            notFound = false
            var text: Text { Text("\(yr)").font(.system(size: 11.5)) }
            ctx.draw(
              text,  // no affine trs frm
              at: point, anchor: UnitPoint(x: 0.0, y: 0.0))  //.bottomLeading)
          }
        }
        if notFound {
          let strDate = Date.formatter.string(from: c.xticks[0].date!)  // => 2023/05/25
          let yr: Int = c.extractYear(strDate)!
          var text: Text { Text("\(yr)").font(.system(size: 11.5)) }
          ctx.draw(
            text,  // no affine trs frm
            at: CGPoint(x: 0.0, y: 0.0), anchor: UnitPoint(x: 0.0, y: 0.0))  //.bottomLeading)
          print("notFound")
        }
    }
  }

  // MARK: - draw 縦軸目盛り線キャプション+横線 & 銘柄コード、銘柄名、特徴
  // ticker2nameの実装が必要
  func gridlines(_ ctx: GraphicsContext, _ size: CGSize) {
    if c.ar.isEmpty { return }
    let h = size.height
    let rect = CGRect(origin: .zero, size: size)  // 描画エリア
    let mtx = CGAffineTransform(
      a: 1.0, b: 0.0, c: 0.0, d: -h / c.qheight, tx: 0.0, ty: h)
    let mt0 = CGAffineTransform.identity.translatedBy(x: 0, y: -c.min)
    var ps = Path()  // 横線(破線)
    c.yticks.forEach { e in
      ps.move(to: CGPoint(x: rect.minX, y: e))
      ps.addLine(to: CGPoint(x: rect.maxX, y: e))
    }
    ctx.stroke(
      ps.applying(mt0).applying(mtx), with: .color(.gray),
      style: StrokeStyle(dash: [2, 2, 2, 2]))

    for e in c.yticks.reversed() {
      let y: Double = -(e - c.min) * h / c.qheight + h
      ctx.draw(
        Text(e.formatNumber).font(.system(size: 10.5)),
        at: CGPoint(x: rect.minX, y: y), anchor: UnitPoint(x: -0.0, y: -0.1))  //.bottomLeading)
    }
    ctx.draw(
      Text(findInfo(c.ticker).joined(separator: ": "))
        .font(.system(size: 10.5)).foregroundColor(.yellow.opacity(0.6)),
      at: CGPoint(x: 0, y: 0), anchor: UnitPoint(x: -0.0, y: -0.1))
  }
  // MARK: - draw 日足 チャート座標系に描画してCanvas Viewの座標系へaffine transform
  func candlestick(_ ctx: GraphicsContext, _ size: CGSize) {
    let width = size.width
    let h = size.height
    let n = c.ar.count
    let w = width / CGFloat(n)
    let mtx = CGAffineTransform(
      a: 1.0, b: 0.0, c: 0.0, d: -h / c.qheight, tx: 0.0, ty: h)
    let mt0 = CGAffineTransform.identity.translatedBy(x: 0, y: -c.min)
    var pf = Path()
    var ps = Path()  // 陽線、白塗り, 陰線、枠だけ

    for (i, e) in c.ar.enumerated() {
      let rect = CGRect(
        x: CGFloat(i) * w, y: min(e.open, e.close), width: w,
        height: abs(e.open - e.close))
      if e.open < e.close {  // 引け値高, 陽線
        pf.addRect(rect)  // addLine can't be contained in fill method
      } else {
        ps.addRect(rect)
      }
      ps.move(to: CGPoint(x: rect.midX, y: rect.maxY))
      ps.addLine(to: CGPoint(x: rect.midX, y: e.high))
      ps.move(to: CGPoint(x: rect.midX, y: rect.minY))
      ps.addLine(to: CGPoint(x: rect.midX, y: e.low))
    }
    ctx.fill(pf.applying(mt0).applying(mtx), with: .color(.blue))
    ctx.stroke(ps.applying(mt0).applying(mtx), with: .color(.blue))
  }
}

#Preview {
  @Previewable @State var selection: String? = "0000"
  VStack(spacing: 0.0) {
    StockView(selection: $selection, typ: .dy)
//    StockView(selected: sels, selection: $selection)
      .frame(width: 400 , height: 260)
    //      StockView(selected: $sels[0])
  }
  .padding(.all, 3)
}
