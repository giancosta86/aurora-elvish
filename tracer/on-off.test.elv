use ./on-off

describe 'Manual on-off tracer' {
  var tracer = (on-off:create)

  var tracer-test-block = {
    $tracer[section] &emoji=🐬 'Description' 'Test content'
  }

  describe 'upon creation' {
    it 'should be disabled' {
      expect-log &stream=err '' $tracer-test-block
    }
  }

  describe 'when enabled' {
    it 'should write to console' {
      $tracer[enable]

      expect-log &stream=err "🐬 Description:\nTest content\n🐬🐬🐬\n" $tracer-test-block
    }
  }

  describe 'when disabled' {
    it 'should remain silent' {
      $tracer[disable]

      expect-log &stream=err '' $tracer-test-block
    }
  }

  describe 'when the enabled is passed via setter' {
    it 'should work' {
      var new-tracer = (on-off:create)
      $new-tracer[set-enabled] $true

      var test-message = '🐞 Hello, world!'

      expect-log &stream=err $test-message"\n" {
        $new-tracer[echo] $test-message
      }
    }
  }
}
