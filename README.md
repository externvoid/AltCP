📅2025/04/25Fr
@FocusState var focusItem: Int?

📅2025/04/24Th
multi modeが動くようになってきた。single mode <--> multi modeの切り替えができる様にしたい。
CodeHist@CatWSのコードが参考になる。
onTapGestureでFocusが当たっているViewを判定出来る。Focusが外れた判定は?
🔹Xcode Short Cutまとめ
1. MiniMap: cmd-N
2. find Selected Text: opt-H
3. find Selected Symbol: cmd-H
4. reveal in Navigator Pane: sft-cmd-J

TODO: コメントを厳選 Carefully select comments

📅2025/04/18Fr
変数、メソッドの説明
- ContentView.swift
  codes: [[String]], ["1711", "(株)ＳＤＳホールディングス", "東証STD", "時価総額2,190百万円", "【特色】省エネ施設の設計・施工で再建図る。太陽光発電事業は大型から自家消費型の施工販売へ転換", "建設業"]
  内側配列の要素数6
  
  
📅2025/04/10Th
TODO:
1. adj補正(split/merge補正)が行われる場所?▶️queryHist@Networker
2. OHLCVの中で補正が行われるのはO, H, L, V(C以外)
3. 銘柄選択popupにてEnterで閉じる▶️TextBoxに検索結果が1件の場合Enterで閉じれば良い

📅2024/10/6St
in AppStorage
1. onChangeでのみNetworkerを呼ぶ様に改良
2. isLoadingを廃止
3. tw.lan/newya/asset/にあるデータベースファイルを~/Library/Application Support/
ChartPlot/へ配置するスクリプト作成
4. 
ToDo:
1. queryCodeTblをChartViewからAppStateへ
2. ar -> dy,wk,mn(日足, 週足, 月足, ar: all record)

📅2024/10/04Fr
in AppStorage brunch
1. @AppStorageの導入に成功
@State -> @StateObject var c: VM
2. plot関数の呼出に条件を付与、if !c.ar.isEmpty
起動プロセスが単純化された

--- init() ---
onAppear @GeometryReader
--- didSet ---
onChange
task
ToDo: Defaultsの導入

📅2024/10/03Th
in AppStorage brunch, @State vs @AppStorage
あれが描かれこれが描かれしているのでonAppearが5回も呼ばれている
🔹@Stage
--- init() ---
onAppear
--- didSet ---
onChange
--- init() ---
onAppear
--- didSet ---
onChange
--- init() ---
onAppear
--- didSet ---
onAppear
--- didSet ---
onChange
onAppear
--- didSet ---

対して画面が現れない事を反映してonAppearの呼び出し回数も少ない
🔹@AppStorage
--- init() ---
onAppear
--- didSet ---
--- init() ---
onAppear
--- didSet ---
onChange
