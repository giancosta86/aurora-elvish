use ./semver

describe 'Parsing a semver' {
  describe 'with all the components' {
    var major = 9
    var minor = 15
    var patch = 7
    var pre-release = 'alpha-a.b-c-somethinglong'
    var build = 'build.1-aef.1-its-okay'

    var source = $major'.'$minor'.'$patch'-'$pre-release'+'$build

    describe 'with the optional leading v' {
      describe 'without the optional leading v' {
        it 'should parse all the components' {
          var semver = (semver:parse $source)

          put $semver[major] |
            should-equal $major

          put $semver[minor] |
            should-equal $minor

          put $semver[patch] |
            should-equal $patch

          put $semver[pre-release] |
            should-equal $pre-release

          put $semver[build] |
            should-equal $build
        }
      }

      describe 'with the optional leading v' {
        it 'should parse all the components' {
          var semver = (semver:parse 'v'$source)

          put $semver[major] |
            should-equal $major

          put $semver[minor] |
            should-equal $minor

          put $semver[patch] |
            should-equal $patch

          put $semver[pre-release] |
            should-equal $pre-release

          put $semver[build] |
            should-equal $build
        }
      }
    }
  }

  describe 'with just the major component' {
    var major = 4
    var semver = (semver:parse $major)

    it 'should have the major component' {
      put $semver[major] |
        should-equal $major
    }

    it 'should have minor and patch set to 0' {
      put $semver[minor] |
        should-equal 0

      put $semver[patch] |
        should-equal 0
    }

    it 'should have pre-release and build set to $nil' {
      put $semver[pre-release] |
        should-be $nil

      put $semver[build] |
        should-be $nil
    }
  }
}