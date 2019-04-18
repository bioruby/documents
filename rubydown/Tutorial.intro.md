# BioRuby Tutorial

## Trying Bioruby

Let's try the following:


~~~ruby
require 'bio'
seq = Bio::Sequence::NA.new("atgcatgcaaaa")

~~~


~~~ruby
seq.complement
~~~


## Working with nucleic / amino acid sequences (Bio::Sequence class)

The Bio::Sequence class allows the usual sequence transformations and translations. In the example below the DNA sequence "atgcatgcaaaa" is converted into the complemental strand and spliced into a subsequence; next, the nucleic acid composition is calculated and the sequence is translated into the amino acid sequence, the molecular weight calculated, and so on. When translating into amino acid sequences, the frame can be specified and optionally the codon table selected (as defined in codontable.rb).

~~~ruby
seq = Bio::Sequence::NA.new("atgcatgcaaaa")
~~~

~~~ruby
# complemental sequence (Bio::Sequence::NA object)
seq.complement
~~~

~~~ruby
seq.subseq(3,8) # gets subsequence of positions 3 to 8 (starting from 1)
~~~

~~~ruby
seq.gc_percent
~~~

~~~ruby
seq.composition
~~~

~~~ruby
seq.translate
~~~

~~~ruby
seq.translate(2)
~~~

~~~ruby
seq.translate(1,11)
~~~

~~~ruby
seq.translate.codes
~~~

~~~ruby
seq.translate.names
~~~

~~~ruby
seq.translate.composition
~~~

~~~ruby
seq.translate.molecular_weight
~~~

~~~ruby
seq.complement.translate
~~~

get a random sequence with the same NA count:

~~~ruby
counts = {'a'=>seq.count('a'),'c'=>seq.count('c'),'g'=>seq.count('g'),'t'=>seq.count('t')}
~~~

~~~ruby
randomseq = Bio::Sequence::NA.randomize(counts)
~~~

~~~ruby
print counts
~~~

~~~ruby
p counts
~~~

The p, print and puts methods are standard Ruby ways of outputting to the screen. If you want to know more about standard Ruby commands you can use the 'ri' command on the command line (or the help command in Windows). For example


~~~
% ri puts
% ri p
% ri File.open
~~~

Nucleic acid sequence are members of the Bio::Sequence::NA class, and amino acid sequence are members of the Bio::Sequence::AA class. Shared methods are in the parent Bio::Sequence class.

As Bio::Sequence inherits Ruby's String class, you can use String class methods. For example, to get a subsequence, you can not only use subseq(from, to) but also String#[].

Please take note that the Ruby's string's are base 0 - i.e. the first letter has index 0, for example:


~~~ruby
s = 'abc'
~~~
~~~ruby
s[0].chr
~~~
~~~ruby
s[0..1]
~~~

So when using String methods, you should subtract 1 from positions conventionally used in biology. (subseq method will throw an exception if you specify positions smaller than or equal to 0 for either one of the "from" or "to".)

The window_search(window_size, step_size) method shows a typical Ruby way of writing concise and clear code using 'closures'. Each sliding window creates a subsequence which is supplied to the enclosed block through a variable named +s+.


- Show average percentage of GC content for 20 bases (stepping the default one base at a time):


~~~ruby

seq = Bio::Sequence::NA.new("atgcatgcaattaagctaatcccaattagatcatcccgatcatcaaaaaaaaaa")
a=[]; seq.window_search(20) { |s| a.push s.gc_percent }
a
~~~

Since the class of each subsequence is the same as original sequence (Bio::Sequence::NA or Bio::Sequence::AA or Bio::Sequence), you can use all methods on the subsequence. For example,

- Shows translation results for 15 bases shifting a codon at a time


~~~ruby
a=[]; seq.window_search(15, 3) { |s| a.push s.translate }
a
~~~

Finally, the window_search method returns the last leftover subsequence. This allows for example

- Divide a genome sequence into sections of 10000bp and output FASTA formatted sequences (line width 60 chars). The 1000bp at the start and end of each subsequence overlapped. At the 3' end of the sequence the leftover is also added:

~~~ruby
i = 1
textwidth=60
remainder = seq.window_search(10000, 9000) do |s|
  puts s.to_fasta("segment #{i}", textwidth)
  i += 1
end
if remainder
  puts remainder.to_fasta("segment #{i}", textwidth)
end
~~~

If you don't want the overlapping window, set window size and stepping size to equal values.

Other examples

* Count the codon usage

~~~ruby
codon_usage = Hash.new(0)
seq.window_search(3, 3) { |s| codon_usage[s] += 1 }
codon_usage
~~~

* Calculate molecular weight for each 10-aa peptide (or 10-nt nucleic acid)

~~~ruby
a=[]; seq.window_search(10, 10) { |s| a.push s.molecular_weight }
~~~


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

