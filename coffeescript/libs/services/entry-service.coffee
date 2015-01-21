angular.module('EntryService', ['DbService'])
.factory 'entries', (db, rfc4122) ->
  class Entry
    constructor: (@sheet, @date, @project = '', @key = null) ->
      @type = 'entry'
      @sheet_id = @sheet.key
      @key ?= rfc4122.v4()

    render: ->
      {
        project: @project
        sheet_id: @sheet_id
        date: @date
        type: @type
        key: @key
      }

    # @TODO: add a entry list view
    @setupViews: ->
      # // document that tells PouchDB/CouchDB
      # // to build up an index on doc.name
      # var myIndex = {
      #   _id: '_design/my_index',
      #   views: {
      #     'my_index': {
      #       map: function (doc) { emit(doc.name); }.toString()
      #     }
      #   }
      # };
      # // save it
      # pouch.put(myIndex).then(function () {
      #   // success!
      # }).catch(function (err) {
      #   // some error (maybe a 409, because it already exists?)
      # });



    @all: (sheet, cb) ->
      map = (doc) ->
        if doc?.type is "entry"
          # order by startdate
          emit(doc.date)

      sheetFilter = (err, response) ->
        if err?
          console.log err
          return []

        matches = _.filter response.rows, (row) ->
          true if row.doc.sheet_id is sheet.key

        cb(matches)

      db.query({map: map}, {include_docs: true, reduce: false}, sheetFilter)

    @new: (sheet, date) ->
      console.log "NEW"
      # entry = { project: '', date: date, type: 'entry' }
      new Entry(sheet, date).render()

    @delete: (item) ->
      db.get(item.key)
      .then (entry) ->
        db.remove(entry)
        .then () ->
          console.log "DELETED #{entry.key}"
        .catch (error) ->
          console.log error
      .catch (error) ->
        console.log error

    @update: (item) ->
      # console.log item
      db.get(item.key)
      .then (entry) ->
        delete item._rev
        delete item._id

        for attr, _ of item
          entry[attr] = item[attr]

        db.put(entry, entry.key)
        .catch (error) ->
          console.log error

      .catch (error) ->
        if error.status is 404
          db.put(item, item.key)
          .catch (error) ->
            console.log error

  Entry
