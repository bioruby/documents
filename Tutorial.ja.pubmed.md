## PubMed を引いて引用文献リストを作る (Bio::PubMed クラス)

次は、NCBI の文献データベース PubMed を検索して引用文献リストを作成する例です。

```ruby
#!/usr/bin/env ruby

require 'bio'

ARGV.each do |id|
  entry = Bio::PubMed.query(id)     # PubMed を取得するクラスメソッド
  medline = Bio::MEDLINE.new(entry) # Bio::MEDLINE オブジェクト
  reference = medline.reference     # Bio::Reference オブジェクト
  puts reference.bibtex             # BibTeX フォーマットで出力
end
```

このスクリプトを pmfetch.rb など好きな名前で保存し、

```sh
% ./pmfetch.rb 11024183 10592278 10592173
```

など引用したい論文の PubMed ID (PMID) を引数に並べると NCBI にアクセスして MEDLINE フォーマットをパースし BibTeX フォーマットに変換して出力してくれるはずです。

他に、キーワードで検索する機能もあります。

```ruby
#!/usr/bin/env ruby

require 'bio'

# コマンドラインで与えたキーワードのリストを１つの文字列にする
keywords = ARGV.join(' ')

# PubMed をキーワードで検索
entries = Bio::PubMed.search(keywords)

entries.each do |entry|
  medline = Bio::MEDLINE.new(entry) # Bio::MEDLINE オブジェクト
  reference = medline.reference     # Bio::Reference オブジェクト
  puts reference.bibtex             # BibTeX フォーマットで出力
end
```

このスクリプトを pmsearch.rb など好きな名前で保存し

```sh
% ./pmsearch.rb genome bioinformatics
```

など検索したいキーワードを引数に並べて実行すると、PubMed をキーワード検索してヒットした論文のリストを BibTeX フォーマットで出力します。

最近では、NCBI は E-Utils というウェブアプリケーションを使うことが推奨されているので、今後は Bio::PubMed.esearch メソッドおよび Bio::PubMed.efetch メソッドを使う方が良いでしょう。

```ruby
#!/usr/bin/env ruby

require 'bio'

keywords = ARGV.join(' ')

options = {
  'maxdate' => '2003/05/31',
  'retmax' => 1000,
}

entries = Bio::PubMed.esearch(keywords, options)

Bio::PubMed.efetch(entries).each do |entry|
  medline = Bio::MEDLINE.new(entry)
  reference = medline.reference
  puts reference.bibtex
end
```

このスクリプトでは、上記の pmsearch.rb とほぼ同じように動きます。さらに、 NCBI E-Utils を活用することにより、検索対象の日付や最大ヒット件数などを指定できるようになっているので、より高機能です。オプションに与えられる引数については [E-Utils のヘルプページ](http://eutils.ncbi.nlm.nih.gov/entrez/query/static/eutils_help.html) を参照してください。

ちなみに、ここでは bibtex メソッドで BibTeX フォーマットに変換していますが、後述のように bibitem メソッドも使える他、（強調やイタリックなど文字の修飾はできませんが）nature メソッドや nar など、いくつかの雑誌のフォーマットにも対応しています。

### BibTeX の使い方のメモ

上記の例で集めた BibTeX フォーマットのリストを TeX で使う方法を簡単にまとめておきます。引用しそうな文献を

```sh
% ./pmfetch.rb 10592173 >> genoinfo.bib
% ./pmsearch.rb genome bioinformatics >> genoinfo.bib
```

などとして genoinfo.bib ファイルに集めて保存しておき、

```latex
\documentclass{jarticle}
\begin{document}
\bibliographystyle{plain}
ほにゃらら KEGG データベース~\cite{PMID:10592173}はふがほげである。
\bibliography{genoinfo}
\end{document}
```

というファイル hoge.tex を書いて、

```sh
% platex hoge
% bibtex hoge   # → genoinfo.bib の処理
% platex hoge   # → 文献リストの作成
% platex hoge   # → 文献番号
```

とすると無事 hoge.dvi ができあがります。

### bibitem の使い方のメモ

文献用に別の .bib ファイルを作りたくない場合は Reference#bibitem メソッドの出力を使います。上記の pmfetch.rb や pmsearch.rb の

```
puts reference.bibtex
```

の行を

```
puts reference.bibitem
```

に書き換えるなどして、出力結果を

```latex
\documentclass{jarticle}
\begin{document}
ほにゃらら KEGG データベース~\cite{PMID:10592173}はふがほげである。

\begin{thebibliography}{00}

\bibitem{PMID:10592173}
Kanehisa, M., Goto, S.
KEGG: kyoto encyclopedia of genes and genomes.,
{\em Nucleic Acids Res}, 28(1):27--30, 2000.

\end{thebibliography}
\end{document}
```

のように \begin{thebibliography} で囲みます。これを hoge.tex とすると

```sh
% platex hoge   # → 文献リストの作成
% platex hoge   # → 文献番号
```

と２回処理すればできあがりです。
