use ./map

describe 'Getting a value from a map' {
  var map = [&a=98 &b=30]

  describe 'when the key exists' {
    it 'should return the related value' {
      var value = (map:get-value $map b)

      (expect $value)[to-equal] 30
    }
  }

  describe 'then the key does not exist' {
    describe 'when the default value is not passed' {
      it 'should return $nil' {
        var value = (map:get-value $map INEXISTING)

        (expect $value)[to-be] $nil
      }
    }

    describe 'when the default value is passed' {
      it 'should be returned' {
        var value = (map:get-value $map INEXISTING &default=4321)

        (expect $value)[to-be] 4321
      }
    }
  }
}

describe 'Getting the entries of a map' {
  describe 'when the map is empty' {
    it 'should put nothing' {
      var entries = [(map:entries [&])]

      (expect $entries)[to-equal] []
    }
  }

  describe 'when the map has entries' {
    it 'should put each of them' {
      var entries = [(map:entries [&a=90 &b=92 &c=95])]

      (expect $entries)[to-equal] [[a 90] [b 92] [c 95]]
    }
  }
}

describe 'Merging maps' {
  describe 'when the maps are empty' {
    it 'should return an empty map' {
      var result = (map:merge [&] [&] [&])

      (expect $result)[to-equal] [&]
    }
  }

  describe 'when the maps have no overlaps' {
    it 'should return a map containing all the keys' {
      var result = (map:merge [&a=90 &b=92] [&c=95 &d=98] [&e=99])

      (expect $result)[to-equal] [&a=90 &b=92 &c=95 &d=98 &e=99]
    }
  }

  describe 'when the maps have overlapping keys' {
    it 'should have keys from the rightmost map' {
      var result = (map:merge [&a=90 &b=92] [&c=95 &a=89] [&a=3 &c=32])

      (expect $result)[to-equal] [&a=3 &b=92 &c=32]
    }
  }
}

describe 'Drilling down a map' {
  var test-map = [
    &a=[
      &b=[
        &c=90
      ]
    ]
  ]

  describe 'when the entire path exists' {
    it 'should return the value' {
      var value = (map:drill-down $test-map a b c)

      (expect $value)[to-be] 90
    }
  }

  describe 'when an intermediate part does not exist' {
    describe 'if a default value is passed' {
      it 'should return the default value' {
        var test-default = 'Some default value'

        var value = (map:drill-down $test-map a INEXISTENT c &default=$test-default)

        (expect $value)[to-be] $test-default
      }
    }

    describe 'if no default value is passed' {
      it 'should return $nil' {
        var value = (map:drill-down $test-map a INEXISTENT c)

        (expect $value)[to-be] $nil
      }
    }
  }
}