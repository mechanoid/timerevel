
angular.module('timerevelConfig', ['pouchdb'])
.factory 'trConfig', (pouchDB) ->

  class TrConfig
    retryReplication: ->
      console.log 'replicate'
      @replicate(@localdb, @remotedb)

    replicate: (localdb, remotedb) ->

      localdb.sync(remotedb, {live: true})
      .catch( (error) =>
        setTimeout(@retryReplication, 5000)
      )

    constructor: ->
      @remotedb = new PouchDB('http://localhost:5984/timerevel')
      @db = @localdb = try
        pouchDB('timerevel')
      catch error
        console.log err

      @replicate(@localdb, @remotedb)



  new TrConfig()
