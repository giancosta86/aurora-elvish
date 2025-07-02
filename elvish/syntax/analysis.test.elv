use ../../fs
use ../../lang
use ./analysis

fn -with-source-temp-tree { |block|
  fs:with-temp-dir { |temp-dir|
    tmp pwd = $temp-dir

    print Alpha > alpha.elv
    print Beta > beta.elv
    print Gamma > gamma.elv

    $block
  }
}

describe 'Analyzing a source directory tree' {
  it 'should potentially provide analysis results for each file' {
    -with-source-temp-tree {

      analysis:analyze-tree [
        { |path content|
          put [
            &text-len=[$content (count $content)]
          ]
        }
      ] | should-be [
        &alpha.elv=[
          &text-len=[Alpha (num 5)]
        ]
        &beta.elv=[
          &text-len=[Beta (num 4)]
        ]
        &gamma.elv=[
          &text-len=[Gamma (num 5)]
        ]
      ]
    }
  }

  it 'should be able to associate multiple results to each file' {
    -with-source-temp-tree {
      analysis:analyze-tree [
        { |path content|
          put [
            &text-len=[$content (count $content)]
            &name-without-extension=$path[..-4]
          ]
        }
      ] | should-be [
        &alpha.elv=[
          &name-without-extension=alpha
          &text-len=[Alpha (num 5)]
        ]
        &beta.elv=[
          &name-without-extension=beta
          &text-len=[Beta (num 4)]
        ]
        &gamma.elv=[
          &name-without-extension=gamma
          &text-len=[Gamma (num 5)]
        ]
      ]
    }
  }

  it 'should not report a path having no analysis result' {
    -with-source-temp-tree {
      var result = (
        analysis:analyze-tree [
          { |path content|
            lang:ternary (!=s Beta $content) [&text-len=[$content (count $content)]] $nil
          }
        ]
      )

      put $result |
        should-be [
          &alpha.elv=[
            &text-len=[Alpha (num 5)]
          ]
          &gamma.elv=[
            &text-len=[Gamma (num 5)]
          ]
        ]
    }
  }
}