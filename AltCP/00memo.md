📅2024/10/05St
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
