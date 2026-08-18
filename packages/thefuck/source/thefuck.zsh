# thefuck's own alias generation costs ~80ms (Python interpreter startup) —
# too slow to pay on every shell launch, so defer it until `fk` is first used.
fk() {
  unfunction fk
  eval "$(thefuck --alias fk)"
  fk "$@"
}
