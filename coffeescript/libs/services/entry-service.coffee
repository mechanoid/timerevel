angular.module('EntryService', ['DbService', 'uuid'])
.factory 'entries', ($q, db, rfc4122) ->
  class Entry
    constructor: (@date, sheet, @project = '', @begin, @end, @intermission, @notice, @tm) ->
      @type = 'entry'
      @sheet_id = sheet._id
      @key ?= rfc4122.v4()

    render: ->
      {
        project: @project
        date: @date
        type: @type
        sheet_id: @sheet_id
        key: @key
        notice: @notice
        begin: @begin
        end: @end
        tm: @tm
        intermission: @intermission
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

      deferred = $q.defer()
      map = (doc) ->
        if doc?.type is "entry"
          # order by startdate
          emit(doc)

      sheetFilter = (err, response) ->
        if err?
          console.log err
          deferred.reject([])

        matches = _.filter response.rows, (row) ->
          if row?.doc?.sheet_id is sheet._id
            row.doc.date = new Date(row.doc.date) if row.doc.begin
            row.doc.begin = new Date(row.doc.begin) if row.doc.begin
            row.doc.end = new Date(row.doc.end) if row.doc.end
            row
        cb?(matches)
        deferred.resolve(matches)

      db.query({map: map}, {include_docs: true}, sheetFilter)
      deferred.promise

    @new: (sheet, date, project, begin, end, intermission, notice, tm) ->
      e = new Entry(date, sheet, project, begin, end, intermission, notice, tm)
      e.render()

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
      db.get(item.key)
      .then (entry) ->
        delete item._rev
        delete item._id

        for attr, _ of item
          entry[attr] = item[attr]

        db.put(entry, entry.key)
        .then ->
          console.log "updated"
        .catch (error) ->
          console.log error

      .catch (error) ->
        console.log "ERROR: ", error
        if error.status is 404
          db.put(item, item.key)
          .then ->
            console.log "created"
          .catch (error) ->
            console.log error

  Entry
