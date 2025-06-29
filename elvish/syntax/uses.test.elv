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
        should-be github.com/giancosta86/aurora-elvish/console
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
        should-be github.com/giancosta86/aurora-elvish/console
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
        should-be ../../alpha/beta
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
        should-be ../../alpha/beta
    }

    it 'should have the declared alias' {
      put $parsed-use[alias] |
        should-be my-beta
    }

    it 'should have namespace equal to its alias' {
      put $parsed-use[namespace] |
        should-be my-beta
    }

    it 'should be of relative kind' {
      put $parsed-use[kind] |
        should-be $uses:relative
    }
  }

  describe 'when parsing multiple uses in the same source code' {
    var parsed-uses = [(uses:parse '
      use str
      use str std-str
      use github.com/giancosta86/aurora-elvish/console
      use github.com/giancosta86/aurora-elvish/console my-console
      use ../../alpha/beta
      use ../../alpha/beta my-beta
      ')]

    it 'should parse them all' {
      count $parsed-uses |
        should-be 6
    }

    it 'should parse the standard import' {
      has-value $parsed-uses [
        &reference=str
        &alias=$nil
        &namespace=str
        &kind=$uses:standard
      ] |
        should-be $true
    }

    it 'should parse the aliased standard import' {
      has-value $parsed-uses [
        &reference=str
        &alias=std-str
        &namespace=std-str
        &kind=$uses:standard
      ] |
        should-be $true
    }

    it 'should parse the absolute import' {
      has-value $parsed-uses [
        &reference=github.com/giancosta86/aurora-elvish/console
        &alias=$nil
        &namespace=console
        &kind=$uses:absolute
      ] |
        should-be $true
    }

    it 'should parse the aliased absolute import' {
      has-value $parsed-uses [
        &reference=github.com/giancosta86/aurora-elvish/console
        &alias=my-console
        &namespace=my-console
        &kind=$uses:absolute
      ] |
        should-be $true
    }

    it 'should parse the relative import' {
      has-value $parsed-uses [
        &reference=../../alpha/beta
        &alias=$nil
        &namespace=beta
        &kind=$uses:relative
      ] |
        should-be $true
    }

    it 'should parse the aliased relative import' {
      has-value $parsed-uses [
        &reference=../../alpha/beta
        &alias=my-beta
        &namespace=my-beta
        &kind=$uses:relative
      ] |
        should-be $true
    }
  }
}
