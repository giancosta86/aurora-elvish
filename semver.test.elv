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

          (expect $semver[major])[to-equal] $major

          (expect $semver[minor])[to-equal] $minor

          (expect $semver[patch])[to-equal] $patch

          (expect $semver[pre-release])[to-equal] $pre-release

          (expect $semver[build])[to-equal] $build
        }
      }

      it 'should parse all the components' {
        var semver = (semver:parse 'v'$source)

        (expect $semver[major])[to-equal] $major

        (expect $semver[minor])[to-equal] $minor

        (expect $semver[patch])[to-equal] $patch

        (expect $semver[pre-release])[to-equal] $pre-release

        (expect $semver[build])[to-equal] $build
      }
    }
  }

  describe 'with just the major component' {
    var major = 4
    var semver = (semver:parse $major)

    it 'should have the major component' {
      (expect $semver[major])[to-equal] $major
    }

    it 'should have minor and patch set to 0' {
      (expect $semver[minor])[to-equal] 0

      (expect $semver[patch])[to-equal] 0
    }

    it 'should have pre-release and build set to $nil' {
      (expect $semver[pre-release])[to-be] $nil

      (expect $semver[build])[to-be] $nil
    }
  }
}