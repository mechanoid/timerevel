angular.module('DbService', ['pouchdb'])
.factory 'db', (pouchDB) ->
  class DbService
    dbName: "timerevel"

    retryReplication: =>
      console.log 'retry replication'
      @replicate(@localdb, @remotedb)

    replicate: (localdb, remotedb) =>
      console.log "start replication"
      localdb.sync(remotedb, {live: true})
      .catch( (error) =>
        setTimeout(@retryReplication, 5000)
      )

    constructor: ->
      @remotedb = try
        new PouchDB("http://localhost:5984/#{@dbName}")
      catch error
        console.log error

      @db = @localdb = try
        new PouchDB(@dbName)
      catch error
        console.log error

      @replicate(@localdb, @remotedb) if @localdb? and @remotedb?

  new DbService().db
