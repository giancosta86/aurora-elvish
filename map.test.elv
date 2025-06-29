use ./map

describe 'Getting a value from a map' {
  var map = [&a=98 &b=30]

  describe 'when the key exists' {
    it 'should return the related value' {
      map:get-value $map b |
        should-be 30
    }
  }

  describe 'when the key does not exist' {
    describe 'when the default value is not passed' {
      it 'should return $nil' {
        map:get-value $map INEXISTING |
          should-be $nil
      }
    }

    describe 'when the default value is passed' {
      it 'should be returned' {
        map:get-value $map INEXISTING &default=4321 |
          should-be 4321
      }
    }
  }
}

describe 'Getting the entries of a map' {
  describe 'when the map is empty' {
    it 'should output nothing' {
      put [(map:entries [&])] |
        should-be []
    }
  }

  describe 'when the map has entries' {
    it 'should output each of them' {
      put [(map:entries [&a=90 &b=92 &c=95])] |
        should-be [[a 90] [b 92] [c 95]]
    }
  }
}

describe 'Getting the values of a map' {
  describe 'when the map is empty' {
    it 'should return an empty list' {
      map:values [&] |
        put [(all)] |
        should-be []
    }
  }

  describe 'when the map has entries' {
    it 'should return the values' {
      map:values [&X90=B &X92=T &X95=A &X98=S] |
        order |
        put [(all)] |
        should-be [A B S T]
    }
  }
}

describe 'Merging maps' {
  describe 'when the maps are empty' {
    it 'should return an empty map' {
      map:merge [&] [&] [&] |
        should-be [&]
    }
  }

  describe 'when the maps have no overlaps' {
    it 'should return a map containing all the keys' {
      map:merge [&a=90 &b=92] [&c=95 &d=98] [&e=99] |
        should-be [&a=90 &b=92 &c=95 &d=98 &e=99]
    }
  }

  describe 'when the maps have overlapping keys' {
    it 'should have keys from the rightmost map' {
      map:merge [&a=90 &b=92] [&c=95 &a=89] [&a=3 &c=32] |
        should-be [&a=3 &b=92 &c=32]
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
      map:drill-down $test-map a b c |
        should-be 90
    }
  }

  describe 'when an intermediate part does not exist' {
    describe 'if a default value is passed' {
      it 'should return the default value' {
        var test-default = 'Some default value'

        map:drill-down $test-map a INEXISTENT c &default=$test-default |
          should-be $test-default
      }
    }

    describe 'if no default value is passed' {
      it 'should return $nil' {
        map:drill-down $test-map a INEXISTENT c |
          should-be $nil
      }
    }
  }
}

describe 'Filter' {
  it 'should work' {
    var source = [
      &a=90
      &b=92
      &c=98
    ]

    map:filter $source { |key value|
      put (and (> $value 90) (!=s $key c))
    } |
      should-be [&b=92]
  }
}