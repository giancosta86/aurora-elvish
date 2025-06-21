use ./command
use ./console

describe 'In console writing to stderr' {
  describe 'echo' {
    it 'should work' {
      var message = 'Dodo'

      expect-log $message"\n" {
        console:echo $message
      }
    }
  }

  describe 'print' {
    it 'should work' {
      var message = 'Dodo'

      expect-log $message {
        console:print $message
      }
    }
  }

  describe 'printf' {
    describe 'when requesting newline' {
      it 'should work' {
        var base = 'Dodo'
        var value = 90

        expect-log $base': '$value"\n" {
          console:printf &newline $base': %s' $value
        }
      }
    }

    describe 'when not requesting newline' {
      it 'should work' {
        var base = 'Dodo'
        var value = 90

        expect-log $base': '$value {
          console:printf $base': %s' $value
        }
      }
    }
  }

  describe 'pprint' {
    it 'should work' {
      expect-log "[\n A\n B\n C\n]\n" {
        console:pprint [ A B C ]
      }
    }
  }

  describe 'inspect' {
    describe 'with a string' {
      it 'should use apostrophes' {
        expect-log "🔎 String: 'A'\n" {
          console:inspect String A
        }
      }
    }

    describe 'with a number' {
      it 'should print the raw value' {
        expect-log "🔎 Number: 98\n" {
          console:inspect Number (num 98)
        }
      }
    }

    describe 'with a list' {
      it 'should pretty-print' {
        expect-log "🔎 List: [\n X\n Y\n Z\n]\n" {
          console:inspect List [ X Y Z ]
        }
      }
    }

    describe 'with a map' {
      it 'should pretty-print' {
        expect-log "🔎 Map: [\n &x=\t90\n &y=\t92\n]\n" {
          console:inspect Map [ &x=90 &y=92 ]
        }
      }
    }
  }

  describe 'inspect-inputs' {
    it 'should-work' {
      expect-log "📥 Inputs: [\n &a=\t90\n &b=\t92\n]\n" {
        console:inspect-inputs [&a=90 &b=92]
      }
    }
  }

  describe 'section' {
    describe 'when a string is passed' {
      it 'should print the string' {
        expect-log "📚 Description:\nTest content\n📚📚📚\n" {
          console:section &emoji=📚 'Description' 'Test content'
        }
      }
    }

    describe 'when a block is passed' {
      it 'should print the block output' {
        expect-log "📚 Description:\nAlpha\nBeta\n🔎 Gamma: 92\n📚📚📚\n" {
          console:section &emoji=📚 'Description' {
            echo Alpha
            echo Beta
            console:inspect Gamma (num 92)
          }
        }
      }
    }
  }
}