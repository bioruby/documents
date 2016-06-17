## GenBank のパース (Bio::GenBank クラス)

GenBank 形式のファイルを用意してください（手元にない場合は、 ftp://ftp.ncbi.nih.gov/genbank/ から .seq ファイルをダウンロードします）。

```sh
% wget ftp://ftp.hgc.jp/pub/mirror/ncbi/genbank/gbphg.seq.gz
% gunzip gbphg.seq.gz
```

まずは、各エントリから ID と説明文、配列を取り出して FASTA 形式に変換してみましょう。

Bio::GenBank::DELIMITER は GenBank クラスで定義されている定数で、データベースごとに異なるエントリの区切り文字（たとえば GenBank の場合は //）を覚えていなくても良いようになっています。

```ruby
#!/usr/bin/env ruby

require 'bio'

while entry = gets(Bio::GenBank::DELIMITER)
  gb = Bio::GenBank.new(entry)      # GenBank オブジェクト

  print ">#{gb.accession} "         # ACCESSION 番号
  puts gb.definition                # DEFINITION 行
  puts gb.naseq                     # 塩基配列（Sequence::NA オブジェクト）
end
```

しかし、この書き方では GenBank ファイルのデータ構造に依存しています。ファイルからのデータ入力を扱うクラス Bio::FlatFile を使用することで、以下のように区切り文字などを気にせず書くことができます。

```ruby
#!/usr/bin/env ruby

require 'bio'

ff = Bio::FlatFile.new(Bio::GenBank, ARGF)
ff.each_entry do |gb|
  definition = "#{gb.accession} #{gb.definition}"
  puts gb.naseq.to_fasta(definition, 60)
end
```

形式の違うデータ、たとえばFASTAフォーマットのファイルを読み込むときでも、

```ruby
#!/usr/bin/env ruby

require 'bio'

ff = Bio::FlatFile.new(Bio::FastaFormat, ARGF)
ff.each_entry do |f|
  puts "definition : " + f.definition
  puts "nalen      : " + f.nalen.to_s
  puts "naseq      : " + f.naseq
end
```

のように、同じような書き方で済ませられます。

さらに、各 Bio::DB クラスの open メソッドで同様のことができます。たとえば、

```ruby
#!/usr/bin/env ruby

require 'bio'

ff = Bio::GenBank.open("gbvrl1.seq")
ff.each_entry do |gb|
  definition = "#{gb.accession} #{gb.definition}"
  puts gb.naseq.to_fasta(definition, 60)    
end
```

などと書くことができます（ただし、この書き方はあまり使われていません)。

次に、GenBank の複雑な FEATURES の中をパースして必要な情報を取り出します。まずは /tranlation="アミノ酸配列" という Qualifier がある場合だけアミノ酸配列を抽出して表示してみます。

```ruby
#!/usr/bin/env ruby

require 'bio'

ff = Bio::FlatFile.new(Bio::GenBank, ARGF)

# GenBank の１エントリごとに
ff.each_entry do |gb|

  # FEATURES の要素を一つずつ処理
  gb.features.each do |feature|

    # Feature に含まれる Qualifier を全てハッシュに変換
    hash = feature.to_hash

    # Qualifier に translation がある場合だけ
    if hash['translation']
      # エントリのアクセッション番号と翻訳配列を表示
      puts ">#{gb.accession}
      puts hash['translation']
    end
  end
end
```

さらに、Feature のポジションに書かれている情報からエントリの塩基配列をスプライシングし、それを翻訳したものと /translation= に書かれていた配列を両方表示して比べてみましょう。

```ruby
#!/usr/bin/env ruby

require 'bio'

ff = Bio::FlatFile.new(Bio::GenBank, ARGF)

# GenBank の１エントリごとに
ff.each_entry do |gb|

  # ACCESSION 番号と生物種名を表示
  puts "### #{gb.accession} - #{gb.organism}"

  # FEATURES の要素を一つずつ処理
  gb.features.each do |feature|

    # Feature の position (join ...など) を取り出す
    position = feature.position

    # Feature に含まれる Qualifier を全てハッシュに変換
    hash = feature.to_hash

    # /translation= がなければスキップ
    next unless hash['translation']

    # /gene=, /product= などの Qualifier から遺伝子名などの情報を集める
    gene_info = [
      hash['gene'], hash['product'], hash['note'], hash['function']
    ].compact.join(', ')
    puts "## #{gene_info}"

    # 塩基配列（position の情報によってスプライシング）
    puts ">NA splicing('#{position}')"
    puts gb.naseq.splicing(position)

    # アミノ酸配列（スプライシングした塩基配列から翻訳）
    puts ">AA translated by splicing('#{position}').translate"
    puts gb.naseq.splicing(position).translate

    # アミノ酸配列（/translation= に書かれていたのもの）
    puts ">AA original translation"
    puts hash['translation']
  end
end
```

もし、使用されているコドンテーブルがデフォルト (universal) と違ったり、最初のコドンが "atg" 以外だったり、セレノシステインが含まれていたり、あるいは BioRuby にバグがあれば、上の例で表示される２つのアミノ酸配列は異なる事になります。

この例で使用されている Bio::Sequence#splicing メソッドは、GenBank, EMBL, DDBJ フォーマットで使われている Location の表記を元に、塩基配列から部分配列を切り出す強力なメソッドです。

この splicing メソッドの引数には GenBank 等の Location の文字列以外に BioRuby の Bio::Locations オブジェクトを渡すことも可能ですが、通常は見慣れている Location 文字列の方が分かりやすいかも知れません。 Location 文字列のフォーマットや Bio::Locations について詳しく知りたい場合は BioRuby の bio/location.rb を見てください。

* GenBank 形式のデータの Feature で使われていた Location 文字列の例

    ```ruby
    naseq.splicing('join(2035..2050,complement(1775..1818),13..345')
    ```

* あらかじめ Locations オブジェクトに変換してから渡してもよい

    ```ruby
    locs = Bio::Locations.new('join((8298.8300)..10206,1..855)')
    naseq.splicing(locs)
    ```

ちなみに、アミノ酸配列 (Bio::Sequence::AA) についても splicing メソッドを使用して部分配列を取り出すことが可能です。

* アミノ酸配列の部分配列を切り出す（シグナルペプチドなど）

    ```ruby
    aaseq.splicing('21..119')
    ```

### GenBank 以外のデータベース

BioRuby では、GenBank 以外のデータベースについても基本的な扱い方は同じで、データベースの１エントリ分の文字列を対応するデータベースのクラスに渡せば、パースされた結果がオブジェクトになって返ってきます。

データベースのフラットファイルから１エントリずつ取り出してパースされたオブジェクトを取り出すには、先にも出てきた Bio::FlatFile を使います。 Bio::FlatFile.new の引数にはデータベースに対応する BioRuby でのクラス名 (Bio::GenBank や Bio::KEGG::GENES など) を指定します。

```ruby
ff = Bio::FlatFile.new(Bio::データベースクラス名, ARGF)
```

しかし、すばらしいことに、実は FlatFile クラスはデータベースの自動認識ができますので、

```ruby
ff = Bio::FlatFile.auto(ARGF)
```

を使うのが一番簡単です。

```ruby
#!/usr/bin/env ruby

require 'bio'

ff = Bio::FlatFile.auto(ARGF)

ff.each_entry do |entry|
  p entry.entry_id          # エントリの ID
  p entry.definition        # エントリの説明文
  p entry.seq               # 配列データベースの場合
end

ff.close
```

さらに、開いたデータベースの閉じ忘れをなくすためには Ruby のブロックを活用して以下のように書くのがよいでしょう。

```ruby
#!/usr/bin/env ruby

require 'bio'

Bio::FlatFile.auto(ARGF) do |ff|
  ff.each_entry do |entry|
    p entry.entry_id          # エントリの ID
    p entry.definition        # エントリの説明文
    p entry.seq               # 配列データベースの場合
  end
end
```

パースされたオブジェクトから、エントリ中のそれぞれの部分を取り出すためのメソッドはデータベース毎に異なります。よくある項目については

* entry_id メソッド → エントリの ID 番号が返る
* definition メソッド → エントリの定義行が返る
* reference メソッド → リファレンスオブジェクトが返る
* organism メソッド → 生物種名
* seq や naseq や aaseq メソッド → 対応する配列オブジェクトが返る

などのように共通化しようとしていますが、全てのメソッドが実装されているわけではありません（共通化の指針は bio/db.rb 参照）。また、細かい部分は各データベースパーザ毎に異なるので、それぞれのドキュメントに従います。

原則として、メソッド名が複数形の場合は、オブジェクトが配列として返ります。たとえば references メソッドを持つクラスは複数の Bio::Reference オブジェクトを Array にして返しますが、別のクラスでは単数形の reference メソッドしかなく、１つの Bio::Reference オブジェクトだけを返す、といった感じです。
