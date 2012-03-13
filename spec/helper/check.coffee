# async check helper
module.exports =

  aCheck: (message, test, timeout = 20) ->
    isDone = false
    runs -> test -> isDone = true
    waitsFor (-> isDone), message, timeout

  aFail: (it, done) -> (msg) => it.fail msg; done()
