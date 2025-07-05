use ./from-env-var

describe 'Tracer based on an environment variable' {
  var test-var = AURORA_TRACER_TEST

  var tracer = (from-env-var:create $test-var)

  var tracer-test-block = {
    $tracer[section] &emoji=🐿 'Description' 'Test content'
  }

  describe 'when the variable is enabled' {
    it 'should write to console' {
      set-env $test-var $from-env-var:enabled

      expect-log &stream=err "🐿 Description:\nTest content\n🐿🐿🐿\n" $tracer-test-block
    }
  }

  describe 'when the variable is disabled' {
    it 'should remain silent' {
      set-env $test-var '<SOME UNRECOGNIZED VALUE>'

      expect-log &stream=err '' $tracer-test-block
    }
  }

  describe 'when the variable is missing' {
    it 'should remain silent' {
      unset-env $test-var

      expect-log &stream=err '' $tracer-test-block
    }
  }
}
