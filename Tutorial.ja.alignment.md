## アライメント (Bio::Alignment クラス)

Bio::Alignment クラスは配列のアライメントを格納するためのコンテナです。 Ruby の Hash や Array に似た操作が可能で、BioPerl の Bio::SimpleAlign に似た感じになっています。以下に簡単な使い方を示します。

```ruby
require 'bio'

seqs = [ 'atgca', 'aagca', 'acgca', 'acgcg' ]
seqs = seqs.collect{ |x| Bio::Sequence::NA.new(x) }

# アライメントオブジェクトを作成
a = Bio::Alignment.new(seqs)

# コンセンサス配列を表示
p a.consensus             # ==> "a?gc?"

# IUPAC 標準の曖昧な塩基を使用したコンセンサス配列を表示
p a.consensus_iupac       # ==> "ahgcr"

# 各配列について繰り返す
a.each { |x| p x }
  # ==>
  #    "atgca"
  #    "aagca"
  #    "acgca"
  #    "acgcg"

# 各サイトについて繰り返す
a.each_site { |x| p x }
  # ==>
  #    ["a", "a", "a", "a"]
  #    ["t", "a", "c", "c"]
  #    ["g", "g", "g", "g"]
  #    ["c", "c", "c", "c"]
  #    ["a", "a", "a", "g"]

# Clustal W を使用してアライメントを行う。
# 'clustalw' コマンドがシステムにインストールされている必要がある。
factory = Bio::ClustalW.new
a2 = a.do_align(factory)
```
