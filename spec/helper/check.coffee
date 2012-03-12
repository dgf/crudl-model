# async jasmine assertion helper that calls 'waitsFor' and 'run' with an existence check
#
# implementation of a failure check requires an outside handling of actual state (overwrite func)
#
# message - should contain a clear test description
# test    - function wrapper that calls the function under test and
#           that accepts a success and an error callback
# assert  - the underlying assertion of actual test context
# timeout - maximum of milli seconds to wait
# func    - response check implemention, default is check of private actual state
module.exports = (message, test, assert, timeout = 70, func = () -> actual) ->
  actual = false
  success = (a = true) -> actual = a
  fail = (msg) -> console.error 'spec check failure: ' + msg
  test success, fail
  waitsFor func, message, timeout
  runs -> assert actual
