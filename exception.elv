use ./map

fn is-return { |e|
  var reason = (map:get-value $e reason)

  if $reason {
    var type = (map:get-value $reason type)
    var name = (map:get-value $reason name)

    if (and (eq $type flow) (eq $name return)) {
      put $true
      return
    }
  }

  put $false
}