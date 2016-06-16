## FASTA による相同性検索を行う（Bio::Fasta クラス）

FASTA 形式の配列ファイル query.pep に対して、自分のマシン(ローカル)あるいはインターネット上のサーバ(リモート)で FASTA による相同性検索を行う方法です。ローカルの場合は SSEARCH なども同様に使うことができます。

### ローカルの場合

FASTA がインストールされていることを確認してください。以下の例では、コマンド名が fasta34 でパスが通ったディレクトリにインストールされている状況を仮定しています。

* ftp://ftp.virginia.edu/pub/fasta/

検索対象とする FASTA 形式のデータベースファイル target.pep と、FASTA 形式の問い合わせ配列がいくつか入ったファイル query.pep を準備します。

この例では、各問い合わせ配列ごとに FASTA 検索を実行し、ヒットした配列の evalue が 0.0001 以下のものだけを表示します。

```ruby
#!/usr/bin/env ruby

require 'bio'

# FASTA を実行する環境オブジェクトを作る（ssearch などでも良い）
factory = Bio::Fasta.local('fasta34', ARGV.pop)

# フラットファイルを読み込み、FastaFormat オブジェクトのリストにする
ff = Bio::FlatFile.new(Bio::FastaFormat, ARGF)

# １エントリずつの FastaFormat オブジェクトに対し
ff.each do |entry|
  # '>' で始まるコメント行の内容を進行状況がわりに標準エラー出力に表示
  $stderr.puts "Searching ... " + entry.definition

  # FASTA による相同性検索を実行、結果は Fasta::Report オブジェクト
  report = factory.query(entry)

  # ヒットしたものそれぞれに対し
  report.each do |hit|
    # evalue が 0.0001 以下の場合
    if hit.evalue < 0.0001
      # その evalue と、名前、オーバーラップ領域を表示
      print "#{hit.query_id} : evalue #{hit.evalue}\t#{hit.target_id} at "
      p hit.lap_at
    end
  end
end
```

ここで factory は繰り返し FASTA を実行するために、あらかじめ作っておく実行環境です。

上記のスクリプトを search.rb とすると、問い合わせ配列とデータベース配列のファイル名を引数にして、以下のように実行します。

```sh
% ruby search.rb query.pep target.pep > search.out
```

FASTA コマンドにオプションを与えたい場合、３番目の引数に FASTA のコマンドラインオプションを書いて渡します。ただし、ktup 値だけはメソッドを使って指定することになっています。たとえば ktup 値を 1 にして、トップ 10 位以内のヒットを得る場合のオプションは、以下のようになります。

```ruby
factory = Bio::Fasta.local('fasta34', 'target.pep', '-b 10')
factory.ktup = 1
```

Bio::Fasta#query メソッドなどの返り値は Bio::Fasta::Report オブジェクトです。この Report オブジェクトから、様々なメソッドで FASTA の出力結果のほぼ全てを自由に取り出せるようになっています。たとえば、ヒットに関するスコアなどの主な情報は、

```ruby
report.each do |hit|
  puts hit.evalue           # E-value
  puts hit.sw               # Smith-Waterman スコア (*)
  puts hit.identity         # % identity
  puts hit.overlap          # オーバーラップしている領域の長さ 
  puts hit.query_id         # 問い合わせ配列の ID
  puts hit.query_def        # 問い合わせ配列のコメント
  puts hit.query_len        # 問い合わせ配列の長さ
  puts hit.query_seq        # 問い合わせ配列
  puts hit.target_id        # ヒットした配列の ID
  puts hit.target_def       # ヒットした配列のコメント
  puts hit.target_len       # ヒットした配列の長さ
  puts hit.target_seq       # ヒットした配列
  puts hit.query_start      # 相同領域の問い合わせ配列での開始残基位置
  puts hit.query_end        # 相同領域の問い合わせ配列での終了残基位置
  puts hit.target_start     # 相同領域のターゲット配列での開始残基位置
  puts hit.target_end       # 相同領域のターゲット配列での終了残基位置
  puts hit.lap_at           # 上記４位置の数値の配列
end
```

などのメソッドで呼び出せます。これらのメソッドの多くは後で説明する Bio::Blast::Report クラスと共通にしてあります。上記以外のメソッドや FASTA 特有の値を取り出すメソッドが必要な場合は、Bio::Fasta::Report クラスのドキュメントを参照してください。

もし、パースする前の手を加えていない fasta コマンドの実行結果が必要な場合には、

```ruby
report = factory.query(entry)
puts factory.output
```

のように、query メソッドを実行した後で factory オブジェクトの output メソッドを使って取り出すことができます。

### リモートの場合

今のところ GenomeNet (fasta.genome.jp) での検索のみサポートしています。リモートの場合は使用可能な検索対象データベースが決まっていますが、それ以外の点については Bio::Fasta.remote と Bio::Fasta.local は同じように使うことができます。

GenomeNet で使用可能な検索対象データベース：

* アミノ酸配列データベース
   * nr-aa, genes, vgenes.pep, swissprot, swissprot-upd, pir, prf, pdbstr
* 塩基配列データベース
   * nr-nt, genbank-nonst, gbnonst-upd, dbest, dbgss, htgs, dbsts, embl-nonst, embnonst-upd, genes-nt, genome, vgenes.nuc

まず、この中から検索したいデータベースを選択します。問い合わせ配列の種類と検索するデータベースの種類によってプログラムは決まります。

* 問い合わせ配列がアミノ酸のとき
   * 対象データベースがアミノ酸配列データベースの場合、program は 'fasta'
   * 対象データベースが核酸配列データベースの場合、program は 'tfasta'
* 問い合わせ配列が核酸配列のとき
   * 対象データベースが核酸配列データベースの場合、program は 'fasta'
   * (対象データベースがアミノ酸配列データベースの場合は検索不能?)

プログラムとデータベースの組み合せが決まったら

```ruby
program = 'fasta'
database = 'genes'

factory = Bio::Fasta.remote(program, database)
```

としてファクトリーを作り、ローカルの場合と同じように factory.query などのメソッドで検索を実行します。
