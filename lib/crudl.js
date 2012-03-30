(function() {
  var Sequelize, findAll, findAndExecute, rawQuery, validateAndSave, _,
    __hasProp = Object.prototype.hasOwnProperty;

  _ = require('underscore');

  Sequelize = require('sequelize');

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
    return model.find(options).error(onError).success(onSuccess);
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

  module.exports = function(model) {
    var interface, method, name, _ref;
    interface = {};
    _ref = model.options.classMethods;
    for (name in _ref) {
      if (!__hasProp.call(_ref, name)) continue;
      method = _ref[name];
      interface[name] = method;
    }
    interface.create = function(values, onSuccess, onError) {
      var instance;
      instance = model.build(values);
      return validateAndSave(instance, onSuccess, onError);
    };
    interface.update = function(options, values, onSuccess, onError) {
      return findAndExecute(model, options, onError, function(instance) {
        var prop, value;
        if (!(instance != null)) {
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
    interface["delete"] = function(options, onSuccess, onError) {
      return findAndExecute(model, options, onError, function(instance) {
        if (instance != null) {
          return instance.destroy().error(onError).success(onSuccess);
        } else {
          return onError('nothing found');
        }
      });
    };
    interface.find = function(options, onSuccess, onError) {
      return findAndExecute(model, options, onError, onSuccess);
    };
    interface.all = function(onSuccess, onError) {
      return findAll(model, null, onSuccess, onError);
    };
    interface.list = function(options, onSuccess, onError) {
      return findAll(model, options, onSuccess, onError);
    };
    interface.persist = function(options, values, onSuccess, onError) {
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
    interface.count = function(onSuccess, onError) {
      return model.count().success(onSuccess).error(onError);
    };
    interface.reset = function(onSuccess, onError) {
      return model.sync({
        force: true
      }).success(onSuccess).error(onError);
    };
    interface.clear = function(onSuccess, onError) {
      return rawQuery(model, 'DELETE FROM ' + model.tableName, onSuccess, onError);
    };
    interface.table = model.tableName;
    return interface;
  };

}).call(this);
