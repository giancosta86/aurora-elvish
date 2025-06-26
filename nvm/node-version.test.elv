#use ../fs
#use ./node-version

var initial-version = v13.0.0

var nvmrc-version = v18.17.1

var package-json-version = v16.14.0

# describe 'Retrieving the requested NodeJS version' {
#   describe 'from a directory containing only .nvmrc' {
#     it 'should emit such version' {
#       fail-test
#     }
#   }

#   describe 'from a directory containing only package.json field' {
#     it 'should emit such version' {
#       fail-test
#     }
#   }

#   describe 'from a directory containing both .nvmrc and package.json field' {
#     it 'should emit the version in .nvmrc' {
#       fail-test
#     }
#   }

#   describe 'from a directory not directly containing such information' {
#     describe 'when an ancestor directory contains .nvmrc' {
#       it 'should emit such version' {
#         fail-test
#       }
#     }

#     describe 'when an ancestor directory contains only package.json field' {
#       it 'should emit such version' {
#         fail-test
#       }
#     }

#     describe 'when an ancestor directory contains both .nvmrc and package.json field' {
#       it 'should emit the version in .nvmrc' {
#         fail-test
#       }
#     }
#   }
# }