#!/bin/bash

echo -e "Study\tSamples\tAvg_++,--\tAvg_+-, -+\tStrandedness\tStrand_Sequenced"

for file in */*all_strandeness.txt; do
  study=$(dirname "$file")
  
  awk -v study="$study" '
  function print_summary() {
      if (n > 0) {
          avg1 = sum1 / n
          avg2 = sum2 / n
          diff = (avg1 > avg2) ? avg1 - avg2 : avg2 - avg1
          strand = (avg1 > avg2) ? "forward (++,--)" : "reverse (+-,-+)"
  
          if (diff > 0.4) {
              strandedness = "stranded"
          } else if (diff < 0.1) {
              strandedness = "unstranded"
              strand = "N/A"
          } else {
              strandedness = "ambiguous"
          }
  
          printf "%s\t%d\t%.4f\t%.4f\t%s\t%s\n", study, n, avg1, avg2, strandedness, strand
      }
  }

  /Fraction of reads explained by "\+\+,--"/ || /Fraction of reads explained by "1\+\+,1--,2\+\-,2-\+"/ {
      sum1 += $NF; n++
  }

  /Fraction of reads explained by "\+\-,-\+"/ || /Fraction of reads explained by "1\+\-,1-\+,2\+\+,2--"/ {
      sum2 += $NF
  }

  END { print_summary() }

  ' "$file"

done
