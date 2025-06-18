use str
use ./resources

describe 'Retrieving a resource' {
  it 'should work' {
    var resources = (resources:for-script (src))

    var license-path = ($resources[get-path] LICENSE)

    var license-content = (slurp < $license-path)

    var has-copyright = (str:contains $license-content Copyright)

    (expect $has-copyright)[to-be] $true
  }
}