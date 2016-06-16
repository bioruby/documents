```
Copyright (C) 2001-2003, 2005, 2006 Toshiaki Katayama <k@bioruby.org>
Copyright (C) 2005, 2006 Naohisa Goto <ng@bioruby.org>
```

# BioRuby の使い方

BioRuby は国産の高機能オブジェクト指向スクリプト言語 Ruby のためのオープンソースなバイオインフォマティクス用ライブラリです。

Ruby 言語は Perl 言語ゆずりの強力なテキスト処理と、シンプルで分かりやすい文法、クリアなオブジェクト指向機能により、広く使われるようになりました。Ruby について詳しくは、ウェブサイトhttp://www.ruby-lang.org/ や市販の書籍等を参照してください。

## はじめに

BioRuby を使用するには Ruby と BioRuby をインストールする必要があります。

### Ruby のインストール

Ruby は Mac OS X や最近の UNIX には通常インストールされています。 Windows の場合も１クリックインストーラや ActiveScriptRuby などが用意されています。まだインストールされていない場合は

* http://jp.rubyist.net/magazine/?0002-FirstProgramming
* http://jp.rubyist.net/magazine/?FirstStepRuby

などを参考にしてインストールしましょう。

あなたのコンピュータにどのバージョンの Ruby がインストールされているかをチェックするには

```sh
% ruby -v
```

とコマンドを入力してください。すると、たとえば

```
ruby 1.8.2 (2004-12-25) [powerpc-darwin7.7.0]
```

のような感じでバージョンが表示されます。バージョン 1.8.5 以降をお勧めします。

Ruby 標準装備のクラスやメソッドについては、Ruby のリファレンスマニュアルを参照してください。

* http://www.ruby-lang.org/ja/man/
* http://doc.okkez.net/

コマンドラインでヘルプを参照するには、Ruby 標準添付の ri コマンドや、日本語版の refe コマンドが便利です。

* http://i.loveruby.net/ja/prog/refe.html

### RubyGems のインストール

RubyGems のページから最新版をダウンロードします。

* http://rubyforge.org/projects/rubygems/

展開してインストールします。

```sh
% tar zxvf rubygems-x.x.x.tar.gz
% cd rubygems-x.x.x
% ruby setup.rb
```

### BioRuby のインストール

BioRuby のインストール方法は http://bioruby.org/archive/ から最新版を取得して以下のように行います(※1)。同梱されている README ファイルにも目を通して頂きたいのですが、慣れないと１日がかりになる BioPerl と比べて BioRuby のインストールはすぐに終わるはずです。

```sh
% wget http://bioruby.org/archive/bioruby-x.x.x.tar.gz
% tar zxvf bioruby-x.x.x.tar.gz
% cd bioruby-x.x.x
% su
# ruby setup.rb
```

RubyGems が使える環境であれば

```sh
% gem install bio
```

だけでインストールできます。このあと README ファイルに書かれているように

```ruby
bioruby-x.x.x/etc/bioinformatics/seqdatabase.ini
```

というファイルをホームディレクトリの ~/.bioinformatics にコピーしておくとよいでしょう。RubyGems の場合は

```ruby
/usr/local/lib/ruby/gems/1.8/gems/bio-x.x.x/
```

などにあるはずです。

```sh
% mkdir ~/.bioinformatics
% cp bioruby-x.x.x/etc/bioinformatics/seqdatabase.ini ~/.bioinformatics
```

また、Emacs エディタを使う人は Ruby のソースに同梱されている misc/ruby-mode.el をインストールしておくとよいでしょう。

```sh
% mkdir -p ~/lib/lisp/ruby
% cp ruby-x.x.x/misc/ruby-mode.el ~/lib/lisp/ruby
```

などとしておいて、~/.emacs に以下の設定を書き足します。

```
; subdirs の設定
(let ((default-directory "~/lib/lisp"))
  (normal-top-level-add-subdirs-to-load-path)

; ruby-mode の設定
(autoload 'ruby-mode "ruby-mode" "Mode for editing ruby source files")
(add-to-list 'auto-mode-alist '("\\.rb$" . rd-mode))
(add-to-list 'interpeter-mode-alist '("ruby" . ruby-mode))
```

## BioRuby シェル

BioRuby バージョン 0.7 以降では、簡単な操作は BioRuby と共にインストールされる bioruby コマンドで行うことができます。bioruby コマンドは Ruby に内蔵されているインタラクティブシェル irb を利用しており、Ruby と BioRuby にできることは全て自由に実行することができます。

```sh
% bioruby project1
```

引数で指定した名前のディレクトリが作成され、その中で解析を行います。上記の例の場合 project1 というディレクトリが作成され、さらに以下のサブディレクトリやファイルが作られます。

```
data/           ユーザの解析ファイルを置く場所
plugin/         必要に応じて追加のプラグインを置く場所
session/        設定やオブジェクト、ヒストリなどが保存される場所
session/config  ユーザの設定を保存したファイル
session/history ユーザの入力したコマンドのヒストリを保存したファイル
session/object  永続化されたオブジェクトの格納ファイル
```

このうち、data ディレクトリはユーザが自由に書き換えて構いません。また、session/history ファイルを見ると、いつどのような操作を行ったかを確認することができます。

２回目以降は、初回と同様に

```sh
% bioruby project1
```

として起動しても構いませんし、作成されたディレクトリに移動して

```sh
% cd project1
% bioruby
```

のように引数なしで起動することもできます。

この他、script コマンドで作成されるスクリプトファイルや、 web コマンドで作成される Rails のための設定ファイルなどがありますが、それらについては必要に応じて後述します。

BioRuby シェルではデフォルトでいくつかの便利なライブラリを読み込んでいます。例えば readline ライブラリが使える環境では Tab キーでメソッド名や変数名が補完されるはずです。open-uri, pp, yaml なども最初から読み込まれています。

### 塩基, アミノ酸の配列を作る

<dl>
<dt>getseq(str)</dt></dl>

getseq コマンド(※2)を使って文字列から塩基配列やアミノ酸配列を作ることができます。塩基とアミノ酸は ATGC の含量が 90% 以上かどうかで自動判定されます。ここでは、できた塩基配列を dna という変数に代入します。

```
bioruby> dna = getseq("atgcatgcaaaa")
```

変数の中身を確認するには Ruby の puts メソッドを使います。

```
bioruby> puts dna
atgcatgcaaaa
```

ファイル名を引数に与えると手元にあるファイルから配列を得ることもできます。 GenBank, EMBL, UniProt, FASTA など主要な配列フォーマットは自動判別されます（拡張子などのファイル名ではなくエントリの中身で判定します）。以下は UniProt フォーマットのエントリをファイルから読み込んでいます。この方法では、複数のエントリがある場合最初のエントリだけが読み込まれます。

```
bioruby> cdc2 = getseq("p04551.sp")
bioruby> puts cdc2
MENYQKVEKIGEGTYGVVYKARHKLSGRIVAMKKIRLEDESEGVPSTAIREISLLKEVNDENNRSN...(略)
```

データベース名とエントリ名が分かっていれば、インターネットを通じて配列を自動的に取得することができます。

```
bioruby> psaB = getseq("genbank:AB044425")
bioruby> puts psaB
actgaccctgttcatattcgtcctattgctcacgcgatttgggatccgcactttggccaaccagca...(略)
```

どこのデータベースからどのような方法でエントリを取得するかは、BioPerl などと共通の OBDA 設定ファイル ~/.bioinformatics/seqdatabase.ini を用いてデータベースごとに指定することができます（後述）。また、EMBOSS の seqret コマンドによる配列取得にも対応していますので、 EMBOSS の USA 表記でもエントリを取得できます。EMBOSS のマニュアルを参照し ~/.embossrc を適切に設定してください。

どの方法で取得した場合も、getseq コマンドによって返される配列は、汎用の配列クラス Bio::Sequence になります(※3)。

配列が塩基配列とアミノ酸配列のどちらと判定されているのかは、 moltype メソッドを用いて

```ruby
bioruby> p cdc2.moltype
Bio::Sequence::AA

bioruby> p psaB.moltype
Bio::Sequence::NA
```

のように調べることができます。自動判定が間違っている場合などには na, aa メソッドで強制的に変換できます。なお、これらのメソッドは元のオブジェクトを強制的に書き換えます。

```ruby
bioruby> dna.aa
bioruby> p dna.moltype
Bio::Sequence::AA

bioruby> dna.na
bioruby> p dna.moltype
Bio::Sequence::NA
```

または、to_naseq, to_aaseq メソッドで強制的に変換することもできます。

```
bioruby> pep = dna.to_aaseq
```

to_naseq, to_aaseq メソッドの返すオブジェクトは、それぞれ、 DNA 配列のための Bio::Sequence::NA クラス、アミノ酸配列のための Bio::Sequence::AA クラスのオブジェクトになります。配列がどちらのクラスに属するかは Ruby の class メソッドを用いて

```ruby
bioruby> p pep.class
Bio::Sequence::AA
```

のように調べることができます。

強制的に変換せずに、Bio::Sequence::NA クラスまたは Bio::sequence::AA クラスのどちらかのオブジェクトを得たい場合には seq メソッドを使います(※4)。

```ruby
bioruby> pep2 = cdc2.seq
bioruby> p pep2.class
Bio::Sequence::AA
```

また、以下で解説する complement や translate などのメソッドの結果は、塩基配列を返すことが期待されるメソッドは Bio::Sequence::NA クラス、アミノ酸配列を返すことが期待されるメソッドは Bio::sequence::AA クラスのオブジェクトになります。

塩基配列やアミノ酸配列のクラスは Ruby の文字列クラスである String を継承しています。また、Bio::Sequence クラスのオブジェクトは String のオブジェクトと見かけ上同様に働くように工夫されています。このため、 length で長さを調べたり、+ で足し合わせたり、* で繰り返したりなど、 Ruby の文字列に対して行える操作は全て利用可能です。このような特徴はオブジェクト指向の強力な側面の一つと言えるでしょう。

```
bioruby> puts dna.length
12

bioruby> puts dna + dna
atgcatgcaaaaatgcatgcaaaa

bioruby> puts dna * 5
atgcatgcaaaaatgcatgcaaaaatgcatgcaaaaatgcatgcaaaaatgcatgcaaaa
```

<dl>
<dt>complement</dt></dl>

塩基配列の相補鎖配列を得るには塩基配列の complement メソッドを呼びます。

```
bioruby> puts dna.complement
ttttgcatgcat
```

<dl>
<dt>translate</dt></dl>

塩基配列をアミノ酸配列に翻訳するには translate メソッドを使います。翻訳されたアミノ酸配列を pep という変数に代入してみます。

```
bioruby> pep = dna.translate
bioruby> puts pep
MHAK
```

フレームを変えて翻訳するには

```ruby
bioruby> puts dna.translate(2)
CMQ
bioruby> puts dna.translate(3)
ACK
```

などとします。

<dl>
<dt>molecular_weight</dt></dl>

分子量は molecular_weight メソッドで表示されます。

```
bioruby> puts dna.molecular_weight
3718.66444

bioruby> puts pep.molecular_weight
485.605
```

<dl>
<dt>seqstat(seq)</dt></dl>

seqstat コマンドを使うと、組成などの情報も一度に表示されます。

```
bioruby> seqstat(dna)

* * * Sequence statistics * * *

5'->3' sequence   : atgcatgcaaaa
3'->5' sequence   : ttttgcatgcat
Translation   1   : MHAK
Translation   2   : CMQ
Translation   3   : ACK
Translation  -1   : FCMH
Translation  -2   : FAC
Translation  -3   : LHA
Length            : 12 bp
GC percent        : 33 %
Composition       : a -  6 ( 50.00 %)
                    c -  2 ( 16.67 %)
                    g -  2 ( 16.67 %)
                    t -  2 ( 16.67 %)
Codon usage       :

 *---------------------------------------------*
 |       |              2nd              |     |
 |  1st  |-------------------------------| 3rd |
 |       |  U    |  C    |  A    |  G    |     |
 |-------+-------+-------+-------+-------+-----|
 | U   U |F  0.0%|S  0.0%|Y  0.0%|C  0.0%|  u  |
 | U   U |F  0.0%|S  0.0%|Y  0.0%|C  0.0%|  c  |
 | U   U |L  0.0%|S  0.0%|*  0.0%|*  0.0%|  a  |
 |  UUU  |L  0.0%|S  0.0%|*  0.0%|W  0.0%|  g  |
 |-------+-------+-------+-------+-------+-----|
 |  CCCC |L  0.0%|P  0.0%|H 25.0%|R  0.0%|  u  |
 | C     |L  0.0%|P  0.0%|H  0.0%|R  0.0%|  c  |
 | C     |L  0.0%|P  0.0%|Q  0.0%|R  0.0%|  a  |
 |  CCCC |L  0.0%|P  0.0%|Q  0.0%|R  0.0%|  g  |
 |-------+-------+-------+-------+-------+-----|
 |   A   |I  0.0%|T  0.0%|N  0.0%|S  0.0%|  u  |
 |  A A  |I  0.0%|T  0.0%|N  0.0%|S  0.0%|  c  |
 | AAAAA |I  0.0%|T  0.0%|K 25.0%|R  0.0%|  a  |
 | A   A |M 25.0%|T  0.0%|K  0.0%|R  0.0%|  g  |
 |-------+-------+-------+-------+-------+-----|
 |  GGGG |V  0.0%|A  0.0%|D  0.0%|G  0.0%|  u  |
 | G     |V  0.0%|A  0.0%|D  0.0%|G  0.0%|  c  |
 | G GGG |V  0.0%|A 25.0%|E  0.0%|G  0.0%|  a  |
 |  GG G |V  0.0%|A  0.0%|E  0.0%|G  0.0%|  g  |
 *---------------------------------------------*

Molecular weight  : 3718.66444
Protein weight    : 485.605
//
```

アミノ酸配列の場合は以下のようになります。

```
bioruby> seqstat(pep)

* * * Sequence statistics * * *

N->C sequence     : MHAK
Length            : 4 aa
Composition       : A Ala - 1 ( 25.00 %) alanine
                    H His - 1 ( 25.00 %) histidine
                    K Lys - 1 ( 25.00 %) lysine
                    M Met - 1 ( 25.00 %) methionine
Protein weight    : 485.605
//
```

<dl>
<dt>composition</dt></dl>

seqstat の中で表示されている組成は composition メソッドで得ることができます。結果が文字列ではなく Hash で返されるので、とりあえず表示してみる場合には puts の代わりに p コマンドを使うと良いでしょう。

```
bioruby> p dna.composition
{"a"=>6, "c"=>2, "g"=>2, "t"=>2}
```

#### 塩基配列、アミノ酸配列のその他のメソッド

他にも塩基配列、アミノ酸配列に対して行える操作は色々とあります。

<dl>
<dt>subseq(from, to)</dt></dl>

部分配列を取り出すには subseq メソッドを使います。

```ruby
bioruby> puts dna.subseq(1, 3)
atg
```

Ruby など多くのプログラミング言語の文字列は 1 文字目を 0 から数えますが、 subseq メソッドは 1 から数えて切り出せるようになっています。

```
bioruby> puts dna[0, 3]
atg
```

Ruby の String クラスが持つ slice メソッド str[] と適宜使い分けるとよいでしょう。

<dl>
<dt>window_search(len, step)</dt></dl>

window_search メソッドを使うと長い配列の部分配列毎の繰り返しを簡単に行うことができます。DNA 配列をコドン毎に処理する場合、３文字ずつずらしながら３文字を切り出せばよいので以下のようになります。

```ruby
bioruby> dna.window_search(3, 3) do |codon|
bioruby+   puts "#{codon}\t#{codon.translate}"
bioruby+ end
atg     M
cat     H
gca     A
aaa     K
```

ゲノム配列を、末端 1000bp をオーバーラップさせながら 11000bp ごとにブツ切りにし FASTA フォーマットに整形する場合は以下のようになります。

```ruby
bioruby> seq.window_search(11000, 10000) do |subseq|
bioruby+   puts subseq.to_fasta
bioruby+ end
```

最後の 10000bp に満たない 3' 端の余り配列は返り値として得られるので、必要な場合は別途受け取って表示します。

```ruby
bioruby> i = 1
bioruby> remainder = seq.window_search(11000, 10000) do |subseq|
bioruby+   puts subseq.to_fasta("segment #{i*10000}", 60)
bioruby+   i += 1
bioruby+ end
bioruby> puts remainder.to_fasta("segment #{i*10000}", 60)
```

<dl>
<dt>splicing(position)</dt></dl>

塩基配列の GenBank 等の position 文字列による切り出しは splicing メソッドで行います。

```ruby
bioruby> puts dna
atgcatgcaaaa
bioruby> puts dna.splicing("join(1..3,7..9)")
atggca
```

<dl>
<dt>randomize</dt></dl>

randomize メソッドは、配列の組成を保存したままランダム配列を生成します。

```
bioruby> puts dna.randomize
agcaatagatac
```

<dl>
<dt>to_re</dt></dl>

to_re メソッドは、曖昧な塩基の表記を含む塩基配列を atgc だけのパターンからなる正規表現に変換します。

```
bioruby> ambiguous = getseq("atgcyatgcatgcatgc")

bioruby> p ambiguous.to_re
/atgc[tc]atgcatgcatgc/

bioruby> puts ambiguous.to_re
(?-mix:atgc[tc]atgcatgcatgc)
```

seq メソッドは ATGC の含有量が 90% 以下だとアミノ酸配列とみなすので、曖昧な塩基が多く含まれる配列の場合は to_naseq メソッドを使って明示的に Bio::Sequence::NA オブジェクトに変換する必要があります。

```
bioruby> s = getseq("atgcrywskmbvhdn").to_naseq
bioruby> p s.to_re
/atgc[ag][tc][at][gc][tg][ac][tgc][agc][atc][atg][atgc]/

bioruby> puts s.to_re
(?-mix:atgc[ag][tc][at][gc][tg][ac][tgc][agc][atc][atg][atgc])
```

<dl>
<dt>names</dt></dl>

あまり使うことはありませんが、配列を塩基名やアミノ酸名に変換するメソッドです。

```
bioruby> p dna.names
["adenine", "thymine", "guanine", "cytosine", "adenine", "thymine",
"guanine", "cytosine", "adenine", "adenine", "adenine", "adenine"]

bioruby> p pep.names
["methionine", "histidine", "alanine", "lysine"]
```

<dl>
<dt>codes</dt></dl>

アミノ酸配列を３文字コードに変換する names と似たメソッドです。

```
bioruby> p pep.codes
["Met", "His", "Ala", "Lys"]
```

<dl>
<dt>gc_percent</dt></dl>

塩基配列の GC 含量は gc_percent メソッドで得られます。

```
bioruby> p dna.gc_percent
33
```

<dl>
<dt>to_fasta</dt></dl>

FASTA フォーマットに変換するには to_fasta メソッドを使います。

```ruby
bioruby> puts dna.to_fasta("dna sequence")
>dna sequence
aaccggttacgt
```

### 塩基やアミノ酸のコード、コドン表をあつかう

アミノ酸、塩基、コドンテーブルを得るための aminoacids, nucleicacids, codontables, codontable コマンドを紹介します。

<dl>
<dt>aminoacids</dt></dl>

アミノ酸の一覧は aminoacids コマンドで表示できます。

```
bioruby> aminoacids
?       Pyl     pyrrolysine
A       Ala     alanine
B       Asx     asparagine/aspartic acid
C       Cys     cysteine
D       Asp     aspartic acid
E       Glu     glutamic acid
F       Phe     phenylalanine
G       Gly     glycine
H       His     histidine
I       Ile     isoleucine
K       Lys     lysine
L       Leu     leucine
M       Met     methionine
N       Asn     asparagine
P       Pro     proline
Q       Gln     glutamine
R       Arg     arginine
S       Ser     serine
T       Thr     threonine
U       Sec     selenocysteine
V       Val     valine
W       Trp     tryptophan
Y       Tyr     tyrosine
Z       Glx     glutamine/glutamic acid
```

返り値は短い表記と対応する長い表記のハッシュになっています。

```
bioruby> aa = aminoacids
bioruby> puts aa["G"]
Gly
bioruby> puts aa["Gly"]
glycine
```

<dl>
<dt>nucleicacids</dt></dl>

塩基の一覧は nucleicacids コマンドで表示できます。

```
bioruby> nucleicacids
a       a       Adenine
t       t       Thymine
g       g       Guanine
c       c       Cytosine
u       u       Uracil
r       [ag]    puRine
y       [tc]    pYrimidine
w       [at]    Weak
s       [gc]    Strong
k       [tg]    Keto
m       [ac]    aroMatic
b       [tgc]   not A
v       [agc]   not T
h       [atc]   not G
d       [atg]   not C
n       [atgc]
```

返り値は塩基の１文字表記と該当する塩基のハッシュになっています。

```
bioruby> na = nucleicacids
bioruby> puts na["r"]
[ag]
```

<dl>
<dt>codontables</dt></dl>

コドンテーブルの一覧は codontables コマンドで表示できます。

```
bioruby> codontables
1       Standard (Eukaryote)
2       Vertebrate Mitochondrial
3       Yeast Mitochondorial
4       Mold, Protozoan, Coelenterate Mitochondrial and Mycoplasma/Spiroplasma
5       Invertebrate Mitochondrial
6       Ciliate Macronuclear and Dasycladacean
9       Echinoderm Mitochondrial
10      Euplotid Nuclear
11      Bacteria
12      Alternative Yeast Nuclear
13      Ascidian Mitochondrial
14      Flatworm Mitochondrial
15      Blepharisma Macronuclear
16      Chlorophycean Mitochondrial
21      Trematode Mitochondrial
22      Scenedesmus obliquus mitochondrial
23      Thraustochytrium Mitochondrial
```

返り値はテーブル番号と名前のハッシュになっています。

```
bioruby> ct = codontables
bioruby> puts ct[3]
Yeast Mitochondorial
```

<dl>
<dt>codontable(num)</dt></dl>

コドン表自体は codontable コマンドで表示できます。

```
bioruby> codontable(11)

 = Codon table 11 : Bacteria

   hydrophilic: H K R (basic), S T Y Q N S (polar), D E (acidic)
   hydrophobic: F L I M V P A C W G (nonpolar)

 *---------------------------------------------*
 |       |              2nd              |     |
 |  1st  |-------------------------------| 3rd |
 |       |  U    |  C    |  A    |  G    |     |
 |-------+-------+-------+-------+-------+-----|
 | U   U | Phe F | Ser S | Tyr Y | Cys C |  u  |
 | U   U | Phe F | Ser S | Tyr Y | Cys C |  c  |
 | U   U | Leu L | Ser S | STOP  | STOP  |  a  |
 |  UUU  | Leu L | Ser S | STOP  | Trp W |  g  |
 |-------+-------+-------+-------+-------+-----|
 |  CCCC | Leu L | Pro P | His H | Arg R |  u  |
 | C     | Leu L | Pro P | His H | Arg R |  c  |
 | C     | Leu L | Pro P | Gln Q | Arg R |  a  |
 |  CCCC | Leu L | Pro P | Gln Q | Arg R |  g  |
 |-------+-------+-------+-------+-------+-----|
 |   A   | Ile I | Thr T | Asn N | Ser S |  u  |
 |  A A  | Ile I | Thr T | Asn N | Ser S |  c  |
 | AAAAA | Ile I | Thr T | Lys K | Arg R |  a  |
 | A   A | Met M | Thr T | Lys K | Arg R |  g  |
 |-------+-------+-------+-------+-------+-----|
 |  GGGG | Val V | Ala A | Asp D | Gly G |  u  |
 | G     | Val V | Ala A | Asp D | Gly G |  c  |
 | G GGG | Val V | Ala A | Glu E | Gly G |  a  |
 |  GG G | Val V | Ala A | Glu E | Gly G |  g  |
 *---------------------------------------------*
```

返り値は Bio::CodonTable クラスのオブジェクトで、コドンとアミノ酸の変換ができるだけでなく、以下のようなデータも得ることができます。

```
bioruby> ct = codontable(2)
bioruby> p ct["atg"]
"M"
```

<dl>
<dt>definition</dt></dl>

コドン表の定義の説明

```
bioruby> puts ct.definition
Vertebrate Mitochondrial
```

<dl>
<dt>start</dt></dl>

開始コドン一覧

```
bioruby> p ct.start
["att", "atc", "ata", "atg", "gtg"]
```

<dl>
<dt>stop</dt></dl>

終止コドン一覧

```
bioruby> p ct.stop
["taa", "tag", "aga", "agg"]
```

<dl>
<dt>revtrans</dt></dl>

アミノ酸をコードするコドンを調べる

```ruby
bioruby> p ct.revtrans("V")
["gtc", "gtg", "gtt", "gta"]
```
