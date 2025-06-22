use str
use ./resources

describe 'Retrieving a resource' {
  it 'should work' {
    var resources = (resources:for-script (src))

    var license-path = ($resources[get-path] LICENSE)

    var license-content = (slurp < $license-path)

    str:contains $license-content Copyright |
      should-be &strictly $true
  }
}