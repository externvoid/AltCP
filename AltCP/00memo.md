
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
