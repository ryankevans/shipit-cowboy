chalk = require 'chalk'
Promise = require 'bluebird'
trash = Promise.promisify(require 'trash')
fse = Promise.promisifyAll(require 'fs-extra')

module.exports = (shipit) ->
  require('shipit-deploy')(shipit)
  require('../helpers/assert-environment')(shipit)

  isCowboy = false

  shipit.blTask 'cowboy', ->
    shipit.assertNotEnvironment 'production', "Cowboy deploys to production are prohibited."
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
      fse.copyAsync shipit.config.cowboySrc, shipit.config.workspace
