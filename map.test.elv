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