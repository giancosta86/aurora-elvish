use ../../lang
use ../../map
use ../../seq

fn analyze-tree { |analyzers|
  put **.elv | seq:reduce [&] { |results-by-file path|
    var file-content = (slurp < $path)

    var results-by-analyzer = (all $analyzers |
      seq:reduce [&] { |cumulated-by-analyzer analyzer|
        var analyzer-result = ($analyzer $path $file-content)

        if $analyzer-result {
          map:merge $cumulated-by-analyzer $analyzer-result
        } else {
          put $cumulated-by-analyzer
        }
    })

    if (seq:is-non-empty $results-by-analyzer) {
      assoc $results-by-file $path $results-by-analyzer
    } else {
      put $results-by-file
    }
  }
}

fn analyze-lines { |content line-number-text-consumer|
  echo $content |
    from-lines |
    seq:enumerate &start-index=1 { |line-number line|
      $line-number-text-consumer $line-number $line
    }
}