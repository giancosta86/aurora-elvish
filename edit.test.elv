use str
use ./edit
use ./files

describe 'Editing a text file' {
  describe 'when the transformer emits a string' {
    it 'should replace the content' {
      var temp-path = (files:temp-path)
      defer { rm -f $temp-path }

      print 'Test' > $temp-path

      edit:file $temp-path { |content|
        put 'X-'$content"\n\n--Y"
      }

      var new-content = (slurp < $temp-path)

      put $new-content |
        should-be "X-Test\n\n--Y"
    }
  }

  describe 'when the transformer emits $nil' {
    it 'should leave the content untouched' {
      var temp-path = (files:temp-path)
      defer { rm -f $temp-path }

      var initial-value = 'Test'

      print $initial-value > $temp-path

      edit:file $temp-path { |content|
        put $nil
      }

      var new-content = (slurp < $temp-path)

      put $new-content |
        should-be $initial-value
    }
  }
}

describe 'Editing a file via jq' {
  it 'should apply the requested transform' {
    var path = (files:temp-path)

    echo '{ "alpha": 90, "beta": 92, "gamma": 95 }' > $path

    fn has-beta {
      var content = (slurp < $path)
      str:contains $content 'beta'
    }

    has-beta |
      should-be &strictly $true

    edit:json $path 'del(.beta)'

    has-beta |
      should-be &strictly $false
  }
}