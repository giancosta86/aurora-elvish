use ./-sdkman/chdir-hooks
use ./-sdkman/paths
use ./-sdkman/wrapper

var sdk-file = $paths:sdk-file

var sdk~ = $wrapper:sdk~

var register-chdir-hooks~ = $chdir-hooks:register~

var get-candidate-dir~ = $paths:get-candidate-dir~

var each-candidate~ = $paths:each-candidate~

fn get-sdk-directory { |candidate version|
  deprecate 'Use get-candidate-dir instead!'

  get-candidate-dir $candidate &version=$version
}

var get-candidate-home-var~ = $paths:get-candidate-home-var~

var setup-sdk-homes~ = $paths:setup-sdk-homes~

fn setup-jvm-homes {
  deprecate 'Use setup-sdk-homes instead'
  setup-sdk-homes
}

var setup-env~ = $chdir-hooks:-after-cd~

fn sdkman { |@arguments|
  deprecate 'Please, call `sdk` instead'

  sdk $@arguments
}

var get-sdkfile-candidates~ = $paths:get-sdkfile-candidates~