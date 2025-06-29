use ../console
use ./uses

fn -parse-single-use { |code|
  var parsed-uses = [(uses:parse $code)]

  if (> (count $parsed-uses) 1) {
    fail 'The test code snippet can only contain one "use" declaration!'
  }

  put $parsed-uses[0]
}

describe 'Parsing the use declarations in Elvish code' {
  describe 'when parsing a standard import' {
    var parsed-use = (-parse-single-use 'use str')

    it 'should have the usual reference' {
      put $parsed-use[reference] |
        should-be str
    }

    it 'should have no alias' {
      put $parsed-use[alias] |
        should-be $nil
    }

    it 'should have namespace given by its reference' {
      put $parsed-use[namespace] |
        should-be str
    }

    it 'should be of standard kind' {
      put $parsed-use[kind] |
        should-be $uses:standard
    }
  }

  describe 'when parsing an aliased standard import' {
    var parsed-use = (-parse-single-use 'use str std-str')

    it 'should have the usual reference' {
      put $parsed-use[reference] |
        should-be str
    }

    it 'should have the declared alias' {
      put $parsed-use[alias] |
        should-be std-str
    }

    it 'should have namespace equal to its alias' {
      put $parsed-use[namespace] |
        should-be std-str
    }

    it 'should be of standard kind' {
      put $parsed-use[kind] |
        should-be $uses:standard
    }
  }

  describe 'when parsing an absolute import' {
    var parsed-use = (-parse-single-use 'use github.com/giancosta86/aurora-elvish/console')

    it 'should have the given reference' {
      put $parsed-use[reference] |
        should-be 'github.com/giancosta86/aurora-elvish/console'
    }

    it 'should have no alias' {
      put $parsed-use[alias] |
        should-be $nil
    }

    it 'should have namespace given by the last component of its reference' {
      put $parsed-use[namespace] |
        should-be console
    }

    it 'should be of absolute kind' {
      put $parsed-use[kind] |
        should-be $uses:absolute
    }
  }

  describe 'when parsing an aliased absolute import' {
    var parsed-use = (-parse-single-use 'use github.com/giancosta86/aurora-elvish/console my-console')

    it 'should have the given reference' {
      put $parsed-use[reference] |
        should-be 'github.com/giancosta86/aurora-elvish/console'
    }

    it 'should have the declared alias' {
      put $parsed-use[alias] |
        should-be my-console
    }

    it 'should have namespace equal to its alias' {
      put $parsed-use[namespace] |
        should-be my-console
    }

    it 'should be of absolute kind' {
      put $parsed-use[kind] |
        should-be $uses:absolute
    }
  }

  describe 'when parsing a relative import' {
    var parsed-use = (-parse-single-use 'use ../../alpha/beta')

    it 'should have the given reference' {
      put $parsed-use[reference] |
        should-be '../../alpha/beta'
    }

    it 'should have no alias' {
      put $parsed-use[alias] |
        should-be $nil
    }

    it 'should have namespace given by the last component of its reference' {
      put $parsed-use[namespace] |
        should-be beta
    }

    it 'should be of relative kind' {
      put $parsed-use[kind] |
        should-be $uses:relative
    }
  }

  describe 'parsing an aliased relative import' {
    var parsed-use = (-parse-single-use 'use ../../alpha/beta my-beta')

    it 'should have the given reference' {
      put $parsed-use[reference] |
        should-be '../../alpha/beta'
    }

    it 'should have the declared alias' {
      put $parsed-use[alias] |
        should-be 'my-beta'
    }

    it 'should have namespace equal to its alias' {
      put $parsed-use[namespace] |
        should-be 'my-beta'
    }

    it 'should be of relative kind' {
      put $parsed-use[kind] |
        should-be $uses:relative
    }
  }
}