## BLAST による相同性検索を行う（Bio::Blast クラス）

BLAST もローカルと GenomeNet (blast.genome.jp) での検索をサポートしています。できるだけ Bio::Fasta と API を共通にしていますので、上記の例を Bio::Blast と書き換えただけでも大丈夫な場合が多いです。

たとえば、先の f_search.rb は

```ruby
# BLAST を実行する環境オブジェクトを作る
factory = Bio::Blast.local('blastp', ARGV.pop)
```

と変更するだけで同じように実行できます。

同様に、GenomeNet を使用してBLASTを行う場合には Bio::Blast.remote を使います。この場合、programの指定内容が FASTA と異なります。

* 問い合わせ配列がアミノ酸のとき
   * 対象データベースがアミノ酸配列データベースの場合、program は 'blastp'
   * 対象データベースが核酸配列データベースの場合、program は 'tblastn'
* 問い合わせ配列が塩基配列のとき
   * 対象データベースがアミノ酸配列データベースの場合、program は 'blastx'
   * 対象データベースが塩基配列データベースの場合、program は 'blastn'
   * (問い合わせ・データベース共に6フレーム翻訳を行う場合は 'tblastx')

をそれぞれ指定します。

ところで、BLAST では "-m 7" オプションによる XML 出力フォーマッットの方が得られる情報が豊富なため、Bio::Blast は Ruby 用の XML ライブラリである XMLParser または REXML が使用可能な場合は、XML 出力を利用します。両方使用可能な場合、XMLParser のほうが高速なので優先的に使用されます。なお、Ruby 1.8.0 以降では REXML は Ruby 本体に標準添付されています。もし XML ライブラリがインストールされていない場合は "-m 8" のタブ区切りの出力形式を扱うようにしています。しかし、このフォーマットでは得られるデータが限られるので、"-m 7" の XML 形式の出力を使うことをお勧めします。

すでに見たように Bio::Fasta::Report と Bio::Blast::Report の Hit オブジェクトはいくつか共通のメソッドを持っています。BLAST 固有のメソッドで良く使いそうなものには bit_score や midline などがあります。

```ruby
report.each do |hit|
  puts hit.bit_score        # bit スコア (*)
  puts hit.query_seq        # 問い合わせ配列
  puts hit.midline          # アライメントの midline 文字列 (*)
  puts hit.target_seq       # ヒットした配列

  puts hit.evalue           # E-value
  puts hit.identity         # % identity
  puts hit.overlap          # オーバーラップしている領域の長さ 
  puts hit.query_id         # 問い合わせ配列の ID
  puts hit.query_def        # 問い合わせ配列のコメント
  puts hit.query_len        # 問い合わせ配列の長さ
  puts hit.target_id        # ヒットした配列の ID
  puts hit.target_def       # ヒットした配列のコメント
  puts hit.target_len       # ヒットした配列の長さ
  puts hit.query_start      # 相同領域の問い合わせ配列での開始残基位置
  puts hit.query_end        # 相同領域の問い合わせ配列での終了残基位置
  puts hit.target_start     # 相同領域のターゲット配列での開始残基位置
  puts hit.target_end       # 相同領域のターゲット配列での終了残基位置
  puts hit.lap_at           # 上記４位置の数値の配列
end
```

FASTAとのAPI共通化のためと簡便のため、スコアなどいくつかの情報は1番目の Hsp (High-scoring segment pair) の値をHitで返すようにしています。

Bio::Blast::Report オブジェクトは、以下に示すような、BLASTの結果出力のデータ構造をそのまま反映した階層的なデータ構造を持っています。具体的には

* Bio::Blast::Report オブジェクトの @iteratinos に
   * Bio::Blast::Report::Iteration オブジェクトの Array が入っており Bio::Blast::Report::Iteration オブジェクトの @hits に
      * Bio::Blast::Report::Hits オブジェクトの Array が入っており Bio::Blast::Report::Hits オブジェクトの @hsps に
         * Bio::Blast::Report::Hsp オブジェクトの Array が入っている

という階層構造になっており、それぞれが内部の値を取り出すためのメソッドを持っています。これらのメソッドの詳細や、BLAST 実行の統計情報などの値が必要な場合には、 bio/appl/blast/*.rb 内のドキュメントやテストコードを参照してください。

### 既存の BLAST 出力ファイルをパースする

BLAST を実行した結果ファイルがすでに保存してあって、これを解析したい場合には（Bio::Blast オブジェクトを作らずに） Bio::Blast::Report オブジェクトを作りたい、ということになります。これには Bio::Blast.reports メソッドを使います。対応しているのは デフォルト出力フォーマット("-m 0") または "-m 7" オプションの XML フォーマット出力です。

```ruby
#!/usr/bin/env ruby

require 'bio'

# BLAST出力を順にパースして Bio::Blast::Report オブジェクトを返す
Bio::Blast.reports(ARGF) do |report|
  puts "Hits for " + report.query_def + " against " + report.db
  report.each do |hit|
    print hit.target_id, "\t", hit.evalue, "\n" if hit.evalue < 0.001
  end
end
```

のようなスクリプト hits_under_0.001.rb を書いて、

```sh
% ./hits_under_0.001.rb *.xml
```

などと実行すれば、引数に与えた BLAST の結果ファイル *.xml を順番に処理できます。

Blast のバージョンや OS などによって出力される XML の形式が異なる可能性があり、時々 XML のパーザがうまく使えないことがあるようです。その場合は Blast 2.2.5 以降のバージョンをインストールするか -D や -m などのオプションの組み合せを変えて試してみてください。

### リモート検索サイトを追加するには

注: このセクションは上級ユーザ向けです。可能であれば SOAP などによるウェブサービスを利用する方がよいでしょう。

Blast 検索は NCBI をはじめ様々なサイトでサービスされていますが、今のところ BioRuby では GenomeNet 以外には対応していません。これらのサイトは、

* CGI を呼び出す（コマンドラインオプションはそのサイト用に処理する）
* -m 8 など BioRuby がパーザを持っている出力フォーマットで blast の出力を取り出す

ことさえできれば、query を受け取って検索結果を Bio::Blast::Report.new に渡すようなメソッドを定義するだけで使えるようになります。具体的には、このメソッドを「exec_サイト名」のような名前で Bio::Blast の private メソッドとして登録すると、４番目の引数に「サイト名」を指定して

```ruby
factory = Bio::Blast.remote(program, db, option, 'サイト名')
```

のように呼び出せるようになっています。完成したら BioRuby プロジェクトまで送ってもらえれば取り込ませて頂きます。
