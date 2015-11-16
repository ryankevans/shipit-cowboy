assert = require 'assert'
chalk = require 'chalk'
Promise = require 'bluebird'
trash = require 'trash'
fse = Promise.promisifyAll(require 'fs-extra')

module.exports = (shipit, prohibitedEnvironments = ['production']) ->
  require('shipit-deploy')(shipit)
  require('../helpers/assert-environment')(shipit)

  isCowboy = false

  shipit.blTask 'cowboy', ->
    shipit.assertNotEnvironment(prohibitedEnvironments,
      "Cowboy deploys to #{shipit.environment} are prohibited.")
    assert shipit.config.cowboySrc?, "cowboySrc not defined"
    isCowboy = true

  shipit.task('deploy', [
    'deploy:init'
    'deploy:cowboy:fetch' # 'deploy:fetch'
    'deploy:update'
    'deploy:publish'
    'deploy:clean'
  ])

  shipit.blTask 'deploy:cowboy:fetch', ->
    shipit.start (if isCowboy then 'deploy:cowboy:copy' else 'deploy:fetch')

  shipit.blTask 'deploy:cowboy:copy', ->
    fse.mkdirsAsync shipit.config.workspace
    .then ->
      shipit.log "Deleting workspace at #{shipit.config.workspace}"
      trash [shipit.config.workspace]
    .then ->
      console.log "Copying from #{shipit.config.cowboySrc} to #{shipit.config.workspace}"
      fse.copyAsync shipit.config.cowboySrc, shipit.config.workspace
    .then ->
      shipit.emit 'fetched'
