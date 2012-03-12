(function() {
  var findAll, findAndExecute, validateAndSave, _,
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
    return model.find(options).error(onError).success(onSuccess);
  };

  findAll = function(model, options, onSuccess, onError) {
    return model.all(options).error(onError).success(function(instances) {
      return onSuccess(_.toArray(instances));
    });
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
        for (prop in values) {
          if (!__hasProp.call(values, prop)) continue;
          value = values[prop];
          instance[prop] = value;
        }
        return validateAndSave(instance, onSuccess, onError);
      });
    };
    interface["delete"] = function(options, onSuccess, onError) {
      return findAndExecute(model, options, onError, function(instance) {
        return instance.destroy().error(onError).success(onSuccess);
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
    interface.reset = function(onSuccess, onError) {
      return model.sync({
        force: true
      }).success(onSuccess).error(onError);
    };
    return interface;
  };

}).call(this);
