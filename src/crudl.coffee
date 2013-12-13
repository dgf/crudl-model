# Sequelize CreateReadUpdateDeleteList delegate (API improvement)
_ = require 'underscore'

class Crudl

  validateAndSave = (instance, onSuccess, onError) ->
    errors = instance.validate()
    if errors
      onError 'validation failed', errors
    else
      instance.save().success(onSuccess).error(onError)

  findAndExecute = (model, options, onError, onSuccess) ->
    if options?
      model.find(options).error(onError).success(onSuccess)
    else
      onError 'empty find query'

  findAll = (model, options, onSuccess, onError)->
    model.findAll(options).error(onError).success (instances) ->
      onSuccess _.toArray(instances)

  rawQuery = (model, query, onSuccess, onError) ->
    model.daoFactoryManager.sequelize.query(query, null, raw: true)
    .success(onSuccess).error(onError)

  constructor: (@model) ->
  # return table name
    @table = @model.tableName

  # build, validate and save
  create: (values, onSuccess, onError) ->
    instance = @model.build values
    validateAndSave instance, onSuccess, onError

  # find, update, validate and save
  update: (options, values, onSuccess, onError) ->
    findAndExecute @model, options, onError, (instance) ->
      unless instance?
        onError 'nothing found'
      else
        instance[prop] = value for own prop, value of values
        validateAndSave instance, onSuccess, onError

  # find and destroy
  destroy: (options, onSuccess, onError) ->
    findAndExecute @model, options, onError, (instance) ->
      if instance?
        instance.destroy().error(onError).success(onSuccess)
      else
        onError 'nothing found'

  find: (options, onSuccess, onError) ->
    findAndExecute @model, options, onError, onSuccess

  # list all instances
  all: (onSuccess, onError) ->
    findAll @model, {}, onSuccess, onError

  # list instances
  list: (options, onSuccess, onError) ->
    findAll @model, options, onSuccess, onError

  # find and update or create
  persist: (options, values, onSuccess, onError) ->
    findAndExecute @model, options, onError, (instance) =>
      if instance?
        instance[prop] = value for own prop, value of values
      else
        instance = @model.build values
      validateAndSave instance, onSuccess, onError

  # count all instances
  count: (onSuccess, onError) ->
    @model.count().success(onSuccess).error(onError)

  # drop table and recreate structure
  reset: (onSuccess, onError) ->
    @model.sync(force: true).success(onSuccess).error(onError)

  # truncate table
  clear: (onSuccess, onError) ->
    rawQuery @model, 'DELETE FROM ' + @model.tableName, onSuccess, onError


module.exports = (model) ->
#
  _.extend model.options.classMethods, new Crudl model
