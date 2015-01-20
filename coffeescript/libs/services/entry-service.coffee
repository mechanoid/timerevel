angular.module('EntryService', ['DbService'])
.factory 'entries', (db, rfc4122) ->
  class Entry
    constructor: (@date, @project = '', @key = null) ->
      @type = 'entry'
      @key ?= rfc4122.v4()

    render: ->
      {
        project: @project
        date: @date
        type: @type
        key: @key
      }

    @all: (sheet) ->
      map = (doc) ->
        if doc?.type == "entry"
          # order by startdate
          emit(doc.date)

      db.query({map: map}, {include_docs: true})
    @new: (date) ->
      # entry = { project: '', date: date, type: 'entry' }
      new Entry(date).render()

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
