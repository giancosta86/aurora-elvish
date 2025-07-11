use os
use str
use ./curl
use ./fs

describe 'cURL' {
  describe 'when not disabling the progress' {
    it 'should display the progress' {
      fs:with-file-sandbox $curl:configuration-path {
        fs:rimraf $curl:configuration-path

        curl gianlucacosta.info -o $os:dev-null 2>curl.log
        defer { fs:rimraf curl.log }

        var log = (slurp < curl.log)

        str:contains $log '%' |
          should-be $true
      }
    }
  }

  describe 'when disabling the progress' {
    it 'should hide the progress' {
      fs:with-file-sandbox $curl:configuration-path {
        curl:disable-non-error-output

        curl gianlucacosta.info -o $os:dev-null 2>curl.log
        defer { fs:rimraf curl.log }

        var log = (slurp < curl.log)

        str:contains $log '%' |
          should-be $false
      }
    }
  }
}