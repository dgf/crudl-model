# Sequelize CreateReadUpdateDeleteList delegate (API improvement)
_ = require 'underscore'

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
      instance[prop] = value for own prop, value of values
      validateAndSave instance, onSuccess, onError

  # find and destroy
  interface.delete = (options, onSuccess, onError) ->
    findAndExecute model, options, onError, (instance) ->
      instance.destroy().error(onError).success(onSuccess)

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

  # drop table and recreate structure
  interface.reset = (onSuccess, onError) ->
    model.sync(force: true).success(onSuccess).error(onError)

  # export model interface
  interface
