angular.module('SheetService', ['DbService', 'uuid'])
.factory 'sheets', (db, rfc4122) ->
  class TrSheets

    @keyForSheet: (year, i) ->
      monthId = "#{parseInt(i)+1}"
      monthId = "0#{monthId}" if monthId.length is 1
      "#{year}-#{monthId}"

    keyForSheet: (year, i) ->
      @constructor.keyForSheet(year, i)

    defaultSheetsForYear: (year) ->
      result = []
      for i, name of ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"]
        i = parseInt(i)
        result.push {type: 'sheet', name: name, key: @keyForSheet(year, i), startDate: new Date(year, i, 1), endDate: new Date(year, i + 1, 0)}
      result

    findOrCreate: (sheet) ->
      db.get(sheet.key)
      .catch (error) ->
        console.log error
        if error.status is 404
          db.put(sheet, "#{sheet.key}")
          .catch (error) ->
            console.log error

    findByKey: (sheetKey) ->
      db.get(sheetKey)
      .catch (error) ->
        # console.log "sheet not found"

    initializeSheetsForYear: (year) ->
      @findOrCreate(sheet) for sheet in @defaultSheetsForYear(year)


    all: ->
      map = (doc) ->
        if doc?.type == "sheet"
          # order by startdate
          emit(doc.startDate)

      db.query({map: map}, {include_docs: true})

    update: (item) =>
      db.get(item._id)
      .then (sheet) =>
        delete item._rev
        delete item._id

        for attr, _ of item
          sheet[attr] = item[attr]

        db.put(sheet, sheet.key)
        .then ->
          console.log 'sheet updated'
        .catch (error) ->
          console.log "update wasn't successful"
          console.log error
      .catch ->
        console.log "sheet not found", item


    constructor: ->

  new TrSheets()
