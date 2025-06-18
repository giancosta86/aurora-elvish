use os
use str
use ./curl
use ./files

describe 'Disabling non-error output for cURL' {
  describe 'when the URL is valid' {
    it 'should hide the progress' {
      files:backup ~/.curlrc {
        curl:disable-non-error-output

        curl gianlucacosta.info -o $os:dev-null 2>curl.log
        defer { rm curl.log }

        var log = (slurp < curl.log)

        var has-header = (str:contains $log '%')

        (expect $has-header)[to-be] $false
      }
    }
  }
}