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
