# BioRuby Tutorial

* Copyright (C) 2001-2003 KATAYAMA Toshiaki &lt;k .at. bioruby.org&gt;
* Copyright (C) 2005-2011 Pjotr Prins, Naohisa Goto and others

This document was last modified: 2011/10/14 Current editor: Michael O'Keefe &lt;okeefm (at) rpi (dot) edu&gt;

The latest version resides in the GIT source code repository:  ./doc/[Tutorial.rd](https://github.com/bioruby/bioruby/blob/master/doc/Tutorial.rd).

## Introduction

This is a tutorial for using Bioruby. A basic knowledge of Ruby is required. If you want to know more about the programming language, we recommend the latest Ruby book [Programming Ruby](http://www.pragprog.com/titles/ruby)by Dave Thomas and Andy Hunt - the first edition can be read online[here](http://www.ruby-doc.org/docs/ProgrammingRuby/).

For BioRuby you need to install Ruby and the BioRuby package on your computer

You can check whether Ruby is installed on your computer and what version it has with the

```sh
% ruby -v
```

command. You should see something like:

```
ruby 1.9.2p290 (2011-07-09 revision 32553) [i686-linux]
```

If you see no such thing you'll have to install Ruby using your installation manager. For more information see the[Ruby](http://www.ruby-lang.org/en/) website.

With Ruby download and install Bioruby using the links on the[Bioruby](http://bioruby.org/) website. The recommended installation is via RubyGems:

```
gem install bio
```

See also the Bioruby [wiki](http://bioruby.open-bio.org/wiki/Installation).

A lot of BioRuby's documentation exists in the source code and unit tests. To really dive in you will need the latest source code tree. The embedded rdoc documentation can be viewed online at[bioruby's rdoc](http://bioruby.org/rdoc/). But first lets start!

## Trying Bioruby

Bioruby comes with its own shell. After unpacking the sources run one of the following commands:

```
bioruby
```

or, from the source tree

```
cd bioruby
ruby -I lib bin/bioruby
```

and you should see a prompt

```
bioruby>
```

Now test the following:

```ruby
bioruby> require 'bio'
bioruby> seq = Bio::Sequence::NA.new("atgcatgcaaaa")
==> "atgcatgcaaaa"

bioruby> seq.complement
==> "ttttgcatgcat"
```

See the the Bioruby shell section below for more tweaking. If you have trouble running examples also check the section below on trouble shooting. You can also post a question to the mailing list. BioRuby developers usually try to help.

## Working with nucleic / amino acid sequences (Bio::Sequence class)

The Bio::Sequence class allows the usual sequence transformations and translations.  In the example below the DNA sequence "atgcatgcaaaa" is converted into the complemental strand and spliced into a subsequence; next, the nucleic acid composition is calculated and the sequence is translated into the amino acid sequence, the molecular weight calculated, and so on. When translating into amino acid sequences, the frame can be specified and optionally the codon table selected (as defined in codontable.rb).

```ruby
bioruby> seq = Bio::Sequence::NA.new("atgcatgcaaaa")
==> "atgcatgcaaaa"

# complemental sequence (Bio::Sequence::NA object)
bioruby> seq.complement
==> "ttttgcatgcat"

bioruby> seq.subseq(3,8) # gets subsequence of positions 3 to 8 (starting from 1)
==> "gcatgc"
bioruby> seq.gc_percent 
==> 33
bioruby> seq.composition 
==> {"a"=>6, "c"=>2, "g"=>2, "t"=>2}
bioruby> seq.translate 
==> "MHAK"
bioruby> seq.translate(2)        # translate from frame 2
==> "CMQ"
bioruby> seq.translate(1,11)     # codon table 11
==> "MHAK"
bioruby> seq.translate.codes
==> ["Met", "His", "Ala", "Lys"]
bioruby> seq.translate.names
==> ["methionine", "histidine", "alanine", "lysine"]
bioruby>  seq.translate.composition
==> {"K"=>1, "A"=>1, "M"=>1, "H"=>1}
bioruby> seq.translate.molecular_weight
==> 485.605
bioruby> seq.complement.translate
==> "FCMH"
```

get a random sequence with the same NA count:

```ruby
bioruby> counts = {'a'=>seq.count('a'),'c'=>seq.count('c'),'g'=>seq.count('g'),'t'=>seq.count('t')}
==> {"a"=>6, "c"=>2, "g"=>2, "t"=>2}
bioruby!> randomseq = Bio::Sequence::NA.randomize(counts) 
==!> "aaacatgaagtc"

bioruby!> print counts
a6c2g2t2  
bioruby!> p counts
{"a"=>6, "c"=>2, "g"=>2, "t"=>2}
```

The p, print and puts methods are standard Ruby ways of outputting to the screen. If you want to know more about standard Ruby commands you can use the 'ri' command on the command line (or the help command in Windows). For example

```sh
% ri puts
% ri p
% ri File.open
```

Nucleic acid sequence are members of the Bio::Sequence::NA class, and amino acid sequence are members of the Bio::Sequence::AA class.  Shared methods are in the parent Bio::Sequence class.

As Bio::Sequence inherits Ruby's String class, you can use String class methods. For example, to get a subsequence, you can not only use subseq(from, to) but also String#[].

Please take note that the Ruby's string's are base 0 - i.e. the first letter has index 0, for example:

```ruby
bioruby> s = 'abc'
==> "abc"
bioruby> s[0].chr
==> "a"
bioruby> s[0..1]
==> "ab"
```

So when using String methods, you should subtract 1 from positions conventionally used in biology.  (subseq method will throw an exception if you specify positions smaller than or equal to 0 for either one of the "from" or "to".)

The window_search(window_size, step_size) method shows a typical Ruby way of writing concise and clear code using 'closures'. Each sliding window creates a subsequence which is supplied to the enclosed block through a variable named +s+.

* Show average percentage of GC content for 20 bases (stepping the default one base at a time):

    ```ruby
    bioruby> seq = Bio::Sequence::NA.new("atgcatgcaattaagctaatcccaattagatcatcccgatcatcaaaaaaaaaa")
    ==> "atgcatgcaattaagctaatcccaattagatcatcccgatcatcaaaaaaaaaa"
    
    bioruby> a=[]; seq.window_search(20) { |s| a.push s.gc_percent } 
    bioruby> a
    ==> [30, 35, 40, 40, 35, 35, 35, 30, 25, 30, 30, 30, 35, 35, 35, 35, 35, 40, 45, 45, 45, 45, 40, 35, 40, 40, 40, 40, 40, 35, 35, 35, 30, 30, 30]
    ```

Since the class of each subsequence is the same as original sequence (Bio::Sequence::NA or Bio::Sequence::AA or Bio::Sequence), you can use all methods on the subsequence. For example,

* Shows translation results for 15 bases shifting a codon at a time

    ```ruby
    bioruby> a = []
    bioruby> seq.window_search(15, 3) { | s | a.push s.translate }
    bioruby> a
    ==> ["MHAIK", "HAIKL", "AIKLI", "IKLIP", "KLIPI", "LIPIR", "IPIRS", "PIRSS", "IRSSR", "RSSRS", "SSRSS", "SRSSK", "RSSKK", "SSKKK"]
    ```

Finally, the window_search method returns the last leftover subsequence. This allows for example

* Divide a genome sequence into sections of 10000bp and output FASTA formatted sequences (line width 60 chars). The 1000bp at the start and end of each subsequence overlapped. At the 3' end of the sequence the leftover is also added:

    ```ruby
    i = 1
    textwidth=60
    remainder = seq.window_search(10000, 9000) do |s|
      puts s.to_fasta("segment #{i}", textwidth)
      i += 1
    end
    if remainder
      puts remainder.to_fasta("segment #{i}", textwidth) 
    end
    ```

If you don't want the overlapping window, set window size and stepping size to equal values.

Other examples

* Count the codon usage

    ```ruby
    bioruby> codon_usage = Hash.new(0)
    bioruby> seq.window_search(3, 3) { |s| codon_usage[s] += 1 }
    bioruby> codon_usage
    ==> {"cat"=>1, "aaa"=>3, "cca"=>1, "att"=>2, "aga"=>1, "atc"=>1, "cta"=>1, "gca"=>1, "cga"=>1, "tca"=>3, "aag"=>1, "tcc"=>1, "atg"=>1}
    ```

* Calculate molecular weight for each 10-aa peptide (or 10-nt nucleic acid)

    ```ruby
    bioruby> a = []
    bioruby> seq.window_search(10, 10) { |s| a.push s.molecular_weight }
    bioruby> a
    ==> [3096.2062, 3086.1962, 3056.1762, 3023.1262, 3073.2262]
    ```

In most cases, sequences are read from files or retrieved from databases. For example:

```ruby
require 'bio'

input_seq = ARGF.read       # reads all files in arguments

my_naseq = Bio::Sequence::NA.new(input_seq)
my_aaseq = my_naseq.translate

puts my_aaseq
```

Save the program above as na2aa.rb. Prepare a nucleic acid sequence described below and save it as my_naseq.txt:

```
gtggcgatctttccgaaagcgatgactggagcgaagaaccaaagcagtgacatttgtctg
atgccgcacgtaggcctgataagacgcggacagcgtcgcatcaggcatcttgtgcaaatg
tcggatgcggcgtga
```

na2aa.rb translates a nucleic acid sequence to a protein sequence. For example, translates my_naseq.txt:

```sh
% ruby na2aa.rb my_naseq.txt
```

or use a pipe!

```sh
% cat my_naseq.txt|ruby na2aa.rb
```

Outputs

```
VAIFPKAMTGAKNQSSDICLMPHVGLIRRGQRRIRHLVQMSDAA*
```

You can also write this, a bit fancifully, as a one-liner script.

```sh
% ruby -r bio -e 'p Bio::Sequence::NA.new($<.read).translate' my_naseq.txt
```

In the next section we will retrieve data from databases instead of using raw sequence files. One generic example of the above can be found in ./sample/na2aa.rb.

## Parsing GenBank data (Bio::GenBank class)

We assume that you already have some GenBank data files. (If you don't, download some .seq files from ftp://ftp.ncbi.nih.gov/genbank/)

As an example we will fetch the ID, definition and sequence of each entry from the GenBank format and convert it to FASTA. This is also an example script in the BioRuby distribution.

A first attempt could be to use the Bio::GenBank class for reading in the data:

```ruby
#!/usr/bin/env ruby

require 'bio'

# Read all lines from STDIN split by the GenBank delimiter
while entry = gets(Bio::GenBank::DELIMITER)
  gb = Bio::GenBank.new(entry)      # creates GenBank object

  print ">#{gb.accession} "         # Accession
  puts gb.definition                # Definition
  puts gb.naseq                     # Nucleic acid sequence 
                                    # (Bio::Sequence::NA object)
end
```

But that has the disadvantage the code is tied to GenBank input. A more generic method is to use Bio::FlatFile which allows you to use different input formats:

```ruby
#!/usr/bin/env ruby

require 'bio'

ff = Bio::FlatFile.new(Bio::GenBank, ARGF)
ff.each_entry do |gb|
  definition = "#{gb.accession} #{gb.definition}"
  puts gb.naseq.to_fasta(definition, 60)
end
```

For example, in turn, reading FASTA format files:

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

In the above two scripts, the first arguments of Bio::FlatFile.new are database classes of BioRuby. This is expanded on in a later section.

Again another option is to use the Bio::DB.open class:

```ruby
#!/usr/bin/env ruby

require 'bio'

ff = Bio::GenBank.open("gbvrl1.seq")
ff.each_entry do |gb|
  definition = "#{gb.accession} #{gb.definition}"
  puts gb.naseq.to_fasta(definition, 60)
end
```

Next, we are going to parse the GenBank 'features', which is normally very complicated:

```ruby
#!/usr/bin/env ruby

require 'bio'

ff = Bio::FlatFile.new(Bio::GenBank, ARGF)

# iterates over each GenBank entry
ff.each_entry do |gb|

  # shows accession and organism
  puts "# #{gb.accession} - #{gb.organism}"

  # iterates over each element in 'features'
  gb.features.each do |feature|
    position = feature.position
    hash = feature.assoc            # put into Hash

    # skips the entry if "/translation=" is not found
    next unless hash['translation']

    # collects gene name and so on and joins it into a string
    gene_info = [
      hash['gene'], hash['product'], hash['note'], hash['function']
    ].compact.join(', ')

    # shows nucleic acid sequence
    puts ">NA splicing('#{position}') : #{gene_info}"
    puts gb.naseq.splicing(position)

    # shows amino acid sequence translated from nucleic acid sequence
    puts ">AA translated by splicing('#{position}').translate"
    puts gb.naseq.splicing(position).translate

    # shows amino acid sequence in the database entry (/translation=)
    puts ">AA original translation"
    puts hash['translation']
  end
end
```

* Note: In this example Feature#assoc method makes a Hash from a feature object. It is useful because you can get data from the hash by using qualifiers as keys. But there is a risk some information is lost  when two or more qualifiers are the same. Therefore an Array is returned by  Feature#feature.

Bio::Sequence#splicing splices subsequences from nucleic acid sequences according to location information used in GenBank, EMBL and DDBJ.

When the specified translation table is different from the default (universal), or when the first codon is not "atg" or the protein contains selenocysteine, the two amino acid sequences will differ.

The Bio::Sequence#splicing method takes not only DDBJ/EMBL/GenBank feature style location text but also Bio::Locations object. For more information about location format and Bio::Locations class, see bio/location.rb.

* Splice according to location string used in a GenBank entry

    ```ruby
    naseq.splicing('join(2035..2050,complement(1775..1818),13..345')
    ```

* Generate Bio::Locations object and pass the splicing method

    ```ruby
    locs = Bio::Locations.new('join((8298.8300)..10206,1..855)')
    naseq.splicing(locs)
    ```

You can also use this splicing method for amino acid sequences (Bio::Sequence::AA objects).

* Splicing peptide from a protein (e.g. signal peptide)

    ```ruby
    aaseq.splicing('21..119')
    ```

### More databases

Databases in BioRuby are essentially accessed like that of GenBank with classes like Bio::GenBank, Bio::KEGG::GENES. A full list can be found in the ./lib/bio/db directory of the BioRuby source tree.

In many cases the Bio::DatabaseClass acts as a factory pattern and recognises the database type automatically - returning a parsed object. For example using Bio::FlatFile class as described above. The first argument of the Bio::FlatFile.new is database class name in BioRuby (such as Bio::GenBank, Bio::KEGG::GENES and so on).

```ruby
ff = Bio::FlatFile.new(Bio::DatabaseClass, ARGF)
```

Isn't it wonderful that Bio::FlatFile automagically recognizes each database class?

```ruby
#!/usr/bin/env ruby

require 'bio'

ff = Bio::FlatFile.auto(ARGF)
ff.each_entry do |entry|
  p entry.entry_id          # identifier of the entry
  p entry.definition        # definition of the entry
  p entry.seq               # sequence data of the entry
end
```

An example that can take any input, filter using a regular expression and output to a FASTA file can be found in sample/any2fasta.rb. With this technique it is possible to write a Unix type grep/sort pipe for sequence information. One example using scripts in the BIORUBY sample folder:

```
fastagrep.rb '/At|Dm/' database.seq | fastasort.rb
```

greps the database for Arabidopsis and Drosophila entries and sorts the output to FASTA.

Other methods to extract specific data from database objects can be different between databases, though some methods are common (see the guidelines for common methods in bio/db.rb).

* entry_id --&gt; gets ID of the entry
* definition --&gt; gets definition of the entry
* reference --&gt; gets references as Bio::Reference object
* organism --&gt; gets species
* seq, naseq, aaseq --&gt; returns sequence as corresponding sequence object

Refer to the documents of each database to find the exact naming of the included methods.

In general, BioRuby uses the following conventions: when a method name is plural, the method returns some object as an Array. For example, some classes have a "references" method which returns multiple Bio::Reference objects as an Array. And some classes have a "reference" method which returns a single Bio::Reference object.

### Alignments (Bio::Alignment)

The Bio::Alignment class in bio/alignment.rb is a container class like Ruby's Hash and Array classes and BioPerl's Bio::SimpleAlign.  A very simple example is:

```ruby
bioruby> seqs = [ 'atgca', 'aagca', 'acgca', 'acgcg' ]
bioruby> seqs = seqs.collect{ |x| Bio::Sequence::NA.new(x) }
# creates alignment object
bioruby> a = Bio::Alignment.new(seqs)
bioruby> a.consensus 
==> "a?gc?"
# shows IUPAC consensus
p a.consensus_iupac       # ==> "ahgcr"

# iterates over each seq
a.each { |x| p x }
  # ==>
  #    "atgca"
  #    "aagca"
  #    "acgca"
  #    "acgcg"
# iterates over each site
a.each_site { |x| p x }
  # ==>
  #    ["a", "a", "a", "a"]
  #    ["t", "a", "c", "c"]
  #    ["g", "g", "g", "g"]
  #    ["c", "c", "c", "c"]
  #    ["a", "a", "a", "g"]

# doing alignment by using CLUSTAL W.
# clustalw command must be installed.
factory = Bio::ClustalW.new
a2 = a.do_align(factory)
```

Read a ClustalW or Muscle 'ALN' alignment file:

```ruby
bioruby> aln = Bio::ClustalW::Report.new(File.read('../test/data/clustalw/example1.aln'))
bioruby> aln.header
==> "CLUSTAL 2.0.9 multiple sequence alignment"
```

Fetch a sequence:

```ruby
bioruby> seq = aln.get_sequence(1)
bioruby> seq.definition
==> "gi|115023|sp|P10425|"
```

Get a partial sequence:

```
bioruby> seq.to_s[60..120]
==> "LGYFNG-EAVPSNGLVLNTSKGLVLVDSSWDNKLTKELIEMVEKKFQKRVTDVIITHAHAD"
```

Show the full alignment residue match information for the sequences in the set:

```
bioruby> aln.match_line[60..120]
==> "     .     **. .   ..   ::*:       . * : : .        .: .* * *"
```

Return a Bio::Alignment object:

```ruby
bioruby> aln.alignment.consensus[60..120]
==> "???????????SN?????????????D??????????L??????????????????H?H?D"
```

## Restriction Enzymes (Bio::RE)

BioRuby has extensive support for restriction enzymes (REs). It contains a full library of commonly used REs (from REBASE) which can be used to cut single stranded RNA or double stranded DNA into fragments. To list all enzymes:

```ruby
rebase = Bio::RestrictionEnzyme.rebase
rebase.each do |enzyme_name, info|
  p enzyme_name
end
```

and to cut a sequence with an enzyme follow up with:

```ruby
res = seq.cut_with_enzyme('EcoRII', {:max_permutations => 0}, 
  {:view_ranges => true})
if res.kind_of? Symbol #error
   err = Err.find_by_code(res.to_s)
   unless err
     err = Err.new(:code => res.to_s)
   end
end
res.each do |frag|
   em = EnzymeMatch.new

   em.p_left = frag.p_left
   em.p_right = frag.p_right
   em.c_left = frag.c_left
   em.c_right = frag.c_right

   em.err = nil
   em.enzyme = ar_enz
   em.sequence = ar_seq
   p em
 end
```
