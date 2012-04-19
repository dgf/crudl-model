(function() {
  var create, destroy, findAll, findAndExecute, persist, rawQuery, update, validateAndSave, _,
    __hasProp = Object.prototype.hasOwnProperty;

  _ = require('underscore');

  validateAndSave = function(instance, onSuccess, onError) {
    var errors;
    errors = instance.validate();
    if (errors) {
      return onError('validation failed', errors);
    } else {
      return instance.save().success(onSuccess).error(onError);
    }
  };

  findAndExecute = function(model, options, onError, onSuccess) {
    if (options != null) {
      return model.find(options).error(onError).success(onSuccess);
    } else {
      return onError('empty find query');
    }
  };

  findAll = function(model, options, onSuccess, onError) {
    return model.all(options).error(onError).success(function(instances) {
      return onSuccess(_.toArray(instances));
    });
  };

  rawQuery = function(model, query, onSuccess, onError) {
    return model.daoFactoryManager.sequelize.query(query, null, {
      raw: true
    }).success(onSuccess).error(onError);
  };

  create = function(model, values, onSuccess, onError) {
    var instance;
    instance = model.build(values);
    return validateAndSave(instance, onSuccess, onError);
  };

  update = function(model, options, values, onSuccess, onError) {
    return findAndExecute(model, options, onError, function(instance) {
      var prop, value;
      if (instance == null) {
        return onError('nothing found');
      } else {
        for (prop in values) {
          if (!__hasProp.call(values, prop)) continue;
          value = values[prop];
          instance[prop] = value;
        }
        return validateAndSave(instance, onSuccess, onError);
      }
    });
  };

  destroy = function(model, options, onSuccess, onError) {
    return findAndExecute(model, options, onError, function(instance) {
      if (instance != null) {
        return instance.destroy().error(onError).success(onSuccess);
      } else {
        return onError('nothing found');
      }
    });
  };

  persist = function(model, options, values, onSuccess, onError) {
    return findAndExecute(model, options, onError, function(instance) {
      var prop, value;
      if (instance != null) {
        for (prop in values) {
          if (!__hasProp.call(values, prop)) continue;
          value = values[prop];
          instance[prop] = value;
        }
      } else {
        instance = model.build(values);
      }
      return validateAndSave(instance, onSuccess, onError);
    });
  };

  module.exports = function(model) {
    return _.extend(model.options.classMethods, {
      create: function(values, onSuccess, onError) {
        return create(model, values, onSuccess, onError);
      },
      update: function(options, values, onSuccess, onError) {
        return update(model, options, values, onSuccess, onError);
      },
      destroy: function(options, onSuccess, onError) {
        return destroy(model, options, onSuccess, onError);
      },
      find: function(options, onSuccess, onError) {
        return findAndExecute(model, options, onError, onSuccess);
      },
      all: function(onSuccess, onError) {
        return findAll(model, null, onSuccess, onError);
      },
      list: function(options, onSuccess, onError) {
        return findAll(model, options, onSuccess, onError);
      },
      persist: function(options, values, onSuccess, onError) {
        return persist(model, options, values, onSuccess, onError);
      },
      count: function(onSuccess, onError) {
        return model.count().success(onSuccess).error(onError);
      },
      reset: function(onSuccess, onError) {
        return model.sync({
          force: true
        }).success(onSuccess).error(onError);
      },
      clear: function(onSuccess, onError) {
        return rawQuery(model, 'DELETE FROM ' + model.tableName, onSuccess, onError);
      },
      table: model.tableName
    });
  };

}).call(this);
