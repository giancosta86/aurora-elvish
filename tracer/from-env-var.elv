use ../tracer

var enabled = true

fn create { |env-var-name|
  tracer:create {
    if (has-env $env-var-name) {
      ==s (get-env $env-var-name) $enabled
    } else {
      put $false
    }
  }
}