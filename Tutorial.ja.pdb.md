## PDB のパース (Bio::PDB クラス)

Bio::PDB は、PDB 形式を読み込むためのクラスです。PDB データベースは PDB, mmCIF, XML (PDBML) の３種類のフォーマットで提供されていますが、これらのうち BioRuby で対応しているのは PDB フォーマットです。

PDB フォーマットの仕様は、以下の Protein Data Bank Contents Guide を参照してください。

* http://www.rcsb.org/pdb/file_formats/pdb/pdbguide2.2/guide2.2_frame.html

### PDB データの読み込み

PDB の１エントリが 1bl8.pdb というファイルに格納されている場合は、 Ruby のファイル読み込み機能を使って

```ruby
entry = File.read("1bl8.pdb")
```

のようにすることで、エントリの内容を文字列として entry という変数に代入することができます。エントリの内容をパースするには

```ruby
pdb = Bio::PDB.new(entry)
```

とします。これでエントリが Bio::PDB オブジェクトとなり、任意のデータを取り出せるようになります。

PDB フォーマットは Bio::FlatFile による自動認識も可能ですが、現在は１ファイルに複数エントリを含む場合には対応していません。 Bio::FlatFile を使って１エントリ分だけ読み込むには、

```ruby
pdb = Bio::FlatFile.auto("1bl8.pdb") { |ff| ff.next_entry }
```

とします。どちらの方法でも変数 pdb には同じ結果が得られます。

### オブジェクトの階層構造

各 PDB エントリは、英数字４文字からなる ID が付けられています。 Bio::PDB オブジェクトから ID を取リ出すには entry_id メソッドを使います。

```
p pdb.entry_id   # => "1BL8"
```

エントリの概要に関する情報も対応するメソッドで取り出すことができます。

```
p pdb.definition # => "POTASSIUM CHANNEL (KCSA) FROM STREPTOMYCES LIVIDANS"
p pdb.keywords   # => ["POTASSIUM CHANNEL", "INTEGRAL MEMBRANE PROTEIN"]
```

他に、登録者や文献、実験方法などの情報も取得できます（それぞれ authors, jrnl, method メソッド）。

PDB データは、基本的には１行が１つのレコードを形成しています。１行に入りきらないデータを複数行に格納する continuation という仕組みも用意されていますが、基本は１行１レコードです。

各行の先頭６文字がその行のデータの種類を示す名前（レコード）になります。 BioRuby では、HEADER レコードに対しては Bio::PDB::Record::HEADER クラス、 TITLE レコードに対しては Bio::PDB::Record::TITLE クラス、というように基本的には各レコードに対応するクラスを１つ用意しています。ただし、REMARK と JRNL レコードに関しては、それぞれ複数のフォーマットが存在するため、複数のクラスを用意しています。

各レコードにアクセスするもっとも単純な方法は record メソッドです。

```ruby
pdb.record("HELIX")
```

のようにすると、その PDB エントリに含まれる全ての HELIX レコードを Bio::PDB::Record::HELIX クラスのオブジェクトの配列として取得できます。

このことをふまえ、以下では、PDB エントリのメインな内容である立体構造に関するデータ構造の扱い方を見ていきます。

#### 原子: Bio::PDB::Record::ATOM, Bio::PDB::Record::HETATM クラス

PDB エントリは、タンパク質、核酸（DNA,RNA）やその他の分子の立体構造、具体的には原子の３次元座標を含んでいます。

タンパク質または核酸の原子の座標は、ATOM レコードに格納されています。対応するクラスは、Bio::PDB::Record::ATOM クラスです。

タンパク質・核酸以外の原子の座標は、HETATM レコードに格納されています。対応するクラスは、Bio::PDB::Record::HETATM クラスです。

HETATM　クラスは ATOM クラスを継承しているため、ATOM と HETATM のメソッドの使い方はまったく同じです。

#### アミノ酸残基（または塩基）: Bio::PDB::Residue クラス

１アミノ酸または１塩基単位で原子をまとめたのが Bio::PDB::Residue です。 Bio::PDB::Residue オブジェクトは、１個以上の Bio::PDB::Record::ATOM オブジェクトを含みます。

#### 化合物: Bio::PDB::Heterogen クラス

タンパク質・核酸以外の分子の原子は、基本的には分子単位で Bio::PDB::Heterogen にまとめられています。 Bio::PDB::Heterogen オブジェクトは、１個以上の Bio::PDB::Record::HETATM オブジェクトを含みます。

#### 鎖（チェイン）: Bio::PDB::Chain クラス

Bio::PDB::Chain は、複数の Bio::PDB::Residue オブジェクトからなる１個のタンパク質または核酸と、複数の Bio::PDB::Heterogen オブジェクトからなる１個以上のそれ以外の分子を格納するデータ構造です。

なお、大半の場合は、タンパク質・核酸（Bio::PDB::Residue）か、それ以外の分子（Bio::PDB::Heterogen）のどちらか一種類しか持ちません。 Chain をひとつしか含まない PDB エントリでは両方持つ場合があるようです。

各 Chain には、英数字１文字の ID が付いています（Chain をひとつしか含まない PDB エントリの場合は空白文字のときもあります）。

#### モデル: Bio::PDB::Model

１個以上の Bio::PDB::Chain が集まったものが Bio::PDB::Model です。Ｘ線結晶構造の場合、Model は通常１個だけですが、NMR 構造の場合、複数の Model が存在することがあります。複数の Model が存在する場合、各 Model にはシリアル番号が付きます。

そして、１個以上の Model が集まったものが、Bio::PDB オブジェクトになります。

### 原子にアクセスするメソッド

Bio::PDB#each_atom は全ての ATOM を順番に１個ずつ辿るイテレータです。

```
pdb.each_atom do |atom|
  p atom.xyz
end
```

この each_atom メソッドは Model, Chain, Residue オブジェクトに対しても使用することができ、それぞれ、その Model, Chain, Residue 内部のすべての ATOM をたどるイテレータとして働きます。

Bio::PDB#atoms は全ての ATOM を配列として返すメソッドです。

```ruby
p pdb.atoms.size        # => 2820 個の ATOM が含まれることがわかる
```

each_atom と同様に atoms メソッドも Model, Chain, Residue オブジェクトに対して使用可能です。

```ruby
pdb.chains.each do |chain|
  p chain.atoms.size    # => 各 Chain 毎の ATOM 数が表示される
end
```

Bio::PDB#each_hetatm は、全ての HETATM を順番に１個ずつ辿るイテレータです。

```
pdb.each_hetatm do |hetatm|
  p hetatm.xyz
end
```

Bio::PDB#hetatms 全ての HETATM を配列として返すのは hetatms メソッドです。

```ruby
p pdb.hetatms.size
```

これらも atoms の場合と同様に、Model, Chain, Heterogen オブジェクトに対して使用可能です。

#### Bio::PDB::Record::ATOM, Bio::PDB::Record::HETATM クラスの使い方

ATOM はタンパク質・核酸（DNA・RNA）を構成する原子、HETATM はそれ以外の原子を格納するためのクラスですが、HETATM が ATOM クラスを継承しているためこれらのクラスでメソッドの使い方はまったく同じです。

```
p atom.serial       # シリアル番号
p atom.name         # 名前
p atom.altLoc       # Alternate location indicator
p atom.resName      # アミノ酸・塩基名または化合物名
p atom.chainID      # Chain の ID
p atom.resSeq       # アミノ酸残基のシーケンス番号
p atom.iCode        # Code for insertion of residues
p atom.x            # X 座標
p atom.y            # Y 座標
p atom.z            # Z 座標
p atom.occupancy    # Occupancy
p atom.tempFactor   # Temperature factor
p atom.segID        # Segment identifier
p atom.element      # Element symbol
p atom.charge       # Charge on the atom
```

これらのメソッド名は、原則として Protein Data Bank Contents Guide の記載に合わせています。メソッド名に resName や resSeq といった記名法（CamelCase）を採用しているのはこのためです。それぞれのメソッドの返すデータの意味は、仕様書を参考にしてください。

この他にも、いくつかの便利なメソッドを用意しています。 xyz メソッドは、座標を３次元のベクトルとして返すメソッドです。このメソッドは、Ruby の Vector クラスを継承して３次元のベクトルに特化させた Bio::PDB::Coordinate クラスのオブジェクトを返します（注: Vectorを継承したクラスを作成するのはあまり推奨されないようなので、将来、Vectorクラスのオブジェクトを返すよう仕様変更するかもしれません）。

```
p atom.xyz
```

ベクトルなので、足し算、引き算、内積などを求めることができます。

```ruby
# 原子間の距離を求める
p (atom1.xyz - atom2.xyz).r  # r はベクトルの絶対値を求めるメソッド

# 内積を求める
p atom1.xyz.inner_product(atom2.xyz)
```

他には、その原子に対応する TER, SIGATM, ANISOU レコードを取得する ter, sigatm, anisou メソッドも用意されています。

### アミノ酸残基 (Residue) にアクセスするメソッド

Bio::PDB#each_residue は、全ての Residue を順番に辿るイテレータです。 each_residue メソッドは、Model, Chain オブジェクトに対しても使用することができ、それぞれの Model, Chain に含まれる全ての Residue を辿るイテレータとして働きます。

```
pdb.each_residue do |residue|
  p residue.resName
end
```

Bio::PDB#residues は、全ての Residue を配列として返すメソッドです。 each_residue と同様に、Model, Chain オブジェクトに対しても使用可能です。

```ruby
p pdb.residues.size
```

### 化合物 (Heterogen) にアクセスするメソッド

Bio::PDB#each_heterogen は全ての Heterogen を順番にたどるイテレータ、 Bio::PDB#heterogens は全ての Heterogen を配列として返すメソッドです。

```ruby
pdb.each_heterogen do |heterogeon|
  p heterogen.resName
end

p pdb.heterogens.size
```

これらのメソッドも Residue と同様に Model, Chain オブジェクトに対しても使用可能です。

### Chain, Model にアクセスするメソッド

同様に、Bio::PDB#each_chain は全ての Chain を順番にたどるイテレータ、 Bio::PDB#chains は全ての Chain を配列として返すメソッドです。これらのメソッドは Model オブジェクトに対しても使用可能です。

Bio::PDB#each_model は全ての Model を順番にたどるイテレータ、 Bio::PDB#models は全ての Model を配列として返すメソッドです。

### PDB Chemical Component Dictionary のデータの読み込み

Bio::PDB::ChemicalComponent クラスは、PDB Chemical Component Dictionary （旧名称 HET Group Dictionary）のパーサです。

PDB Chemical Component Dictionary については以下のページを参照してください。

* http://deposit.pdb.org/cc_dict_tut.html

データは以下でダウンロードできます。

* http://deposit.pdb.org/het_dictionary.txt

このクラスは、RESIDUE から始まって空行で終わる１エントリをパースします（PDB フォーマットにのみ対応しています）。

Bio::FlatFile によるファイル形式自動判別に対応しています。このクラス自体は ID から化合物を検索したりする機能は持っていません。 br_bioflat.rb によるインデックス作成には対応していますので、必要ならそちらを使用してください。

```ruby
Bio::FlatFile.auto("het_dictionary.txt") |ff|
  ff.each do |het|
    p het.entry_id  # ID
    p het.hetnam    # HETNAM レコード（化合物の名称）
    p het.hetsyn    # HETSYM レコード（化合物の別名の配列）
    p het.formul    # FORMUL レコード（化合物の組成式）
    p het.conect    # CONECT レコード
  end
end
```

最後の conect メソッドは、化合物の結合を Hash として返します。たとえば、エタノールのエントリは次のようになりますが、

```
RESIDUE   EOH      9
CONECT      C1     4 C2   O   1H1  2H1
CONECT      C2     4 C1  1H2  2H2  3H2
CONECT      O      2 C1   HO
CONECT     1H1     1 C1
CONECT     2H1     1 C1
CONECT     1H2     1 C2
CONECT     2H2     1 C2
CONECT     3H2     1 C2
CONECT      HO     1 O
END
HET    EOH              9
HETNAM     EOH ETHANOL
FORMUL      EOH    C2 H6 O1
```

このエントリに対して conect メソッドを呼ぶと

```
{ "C1"  => [ "C2", "O", "1H1", "2H1" ], 
  "C2"  => [ "C1", "1H2", "2H2", "3H2" ], 
  "O"   => [ "C1", "HO" ], 
  "1H1" => [ "C1" ], 
  "1H2" => [ "C2" ], 
  "2H1" => [ "C1" ], 
  "2H2" => [ "C2" ], 
  "3H2" => [ "C2" ], 
  "HO"  => [ "O" ] }
```

という Hash を返します。

ここまでの処理を BioRuby シェルで試すと以下のようになります。

```ruby
# PDB エントリ 1bl8 をネットワーク経由で取得
bioruby> ent_1bl8 = getent("pdb:1bl8")
# エントリの中身を確認
bioruby> head ent_1bl8
# エントリをファイルに保存
bioruby> savefile("1bl8.pdb", ent_1bl8)
# 保存されたファイルの中身を確認
bioruby> disp "data/1bl8.pdb"
# PDB エントリをパース
bioruby> pdb_1bl8 = flatparse(ent_1bl8)
# PDB のエントリ ID を表示
bioruby> pdb_1bl8.entry_id
# getent("pdb:1bl8") して flatparse する代わりに、以下でもOK
bioruby> obj_1bl8 = getobj("pdb:1bl8")
bioruby> obj_1bl8.entry_id
# 各 HETEROGEN ごとに残基名を表示
bioruby> pdb_1bl8.each_heterogen { |heterogen| p heterogen.resName }

# PDB Chemical Component Dictionary を取得
bioruby> het_dic = open("http://deposit.pdb.org/het_dictionary.txt").read
# 取得したファイルのバイト数を確認
bioruby> het_dic.size
# 取得したファイルを保存
bioruby> savefile("data/het_dictionary.txt", het_dic)
# ファイルの中身を確認
bioruby> disp "data/het_dictionary.txt"
# 検索のためにインデックス化し het_dic というデータベースを作成
bioruby> flatindex("het_dic", "data/het_dictionary.txt")
# ID が EOH のエタノールのエントリを検索
bioruby> ethanol = flatsearch("het_dic", "EOH")
# 取得したエントリをパース
bioruby> osake = flatparse(ethanol)
# 原子間の結合テーブルを表示
bioruby> sake.conect
```
