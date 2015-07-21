assert = require 'assert'
_ = require 'lodash'

module.exports = (shipit) ->
  shipit.assertEnvironment = (environments, allowed=true, msg=null) ->
    environments = [].concat(environments) # coerce single value to array
    assert(allowed == _.includes(environments, shipit.environment),
      msg || "environment mismatch: [ " + environments.join(', ') + " ]"
    )

  shipit.assertIsEnvironment = (allowedEnvironments, msg) ->
    shipit.assertEnvironment allowedEnvironments, true, msg

  shipit.assertNotEnvironment = (disallowedEnvironments, msg) ->
    shipit.assertEnvironment disallowedEnvironments, false, msg
