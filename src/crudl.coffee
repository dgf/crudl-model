# Sequelize CreateReadUpdateDeleteList delegate (API improvement)
_ = require 'underscore'
Sequelize = require 'sequelize'

validateAndSave = (instance, onSuccess, onError) ->
  errors = instance.validate()
  if errors
    onError 'validation failed', errors
  else
    instance.save().success(onSuccess).error(onError)

findAndExecute = (model, options, onError, onSuccess) ->
  model.find(options).error(onError).success(onSuccess)

findAll = (model, options, onSuccess, onError)->
  model.all(options).error(onError).success (instances) -> onSuccess _.toArray(instances)

rawQuery = (model, query, onSuccess, onError) ->
  model.daoFactoryManager.sequelize.query(query, null, raw: true).success(onSuccess).error(onError)

module.exports = (model) ->
  interface = {}

  # export model class methods
  interface[name] = method for own name, method of model.options.classMethods

  # build, validate and save
  interface.create = (values, onSuccess, onError) ->
    instance = model.build values
    validateAndSave instance, onSuccess, onError

  # find, update, validate and save
  interface.update = (options, values, onSuccess, onError) ->
    findAndExecute model, options, onError, (instance) ->
      if not instance?
        onError 'nothing found'
      else
        instance[prop] = value for own prop, value of values
        validateAndSave instance, onSuccess, onError

  # find and destroy
  interface.delete = (options, onSuccess, onError) ->
    findAndExecute model, options, onError, (instance) ->
      if instance?
        instance.destroy().error(onError).success(onSuccess)
      else
        onError 'nothing found'

  # find an instance
  interface.find = (options, onSuccess, onError) ->
    findAndExecute model, options, onError, onSuccess

  # list all instances
  interface.all = (onSuccess, onError) ->
    findAll model, null, onSuccess, onError

  # list instances
  interface.list = (options, onSuccess, onError) ->
    findAll model, options, onSuccess, onError

  # find and update or create
  interface.persist = (options, values, onSuccess, onError) ->
    findAndExecute model, options, onError, (instance) ->
      if instance?
        instance[prop] = value for own prop, value of values
      else
        instance = model.build values
      validateAndSave instance, onSuccess, onError

  # count all instances
  interface.count = (onSuccess, onError) ->
    model.count().success(onSuccess).error(onError)

  # drop table and recreate structure
  interface.reset = (onSuccess, onError) ->
    model.sync(force: true).success(onSuccess).error(onError)

  # truncate table
  interface.clear = (onSuccess, onError) ->
    rawQuery model, 'DELETE FROM ' + model.tableName, onSuccess, onError

  # export model interface
  interface
