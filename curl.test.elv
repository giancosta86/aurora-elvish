use os
use str
use ./curl
use ./files

describe 'cURL' {
  describe 'when not disabling the progress' {
    it 'should display the progress' {
      files:preserve-state $curl:configuration-path {
        rm $curl:configuration-path

        curl gianlucacosta.info -o $os:dev-null 2>curl.log
        defer { rm curl.log }

        var log = (slurp < curl.log)

        str:contains $log '%' |
          should-be &strictly $true
      }
    }
  }

  describe 'when disabling the progress' {
    it 'should hide the progress' {
      files:preserve-state $curl:configuration-path {
        curl:disable-non-error-output

        curl gianlucacosta.info -o $os:dev-null 2>curl.log
        defer { rm curl.log }

        var log = (slurp < curl.log)

        str:contains $log '%' |
          should-be &strictly $false
      }
    }
  }
}