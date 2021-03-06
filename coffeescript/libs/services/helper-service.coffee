angular.module('HelperService', [])
.factory 'helper', (db, sheets) ->
  class Helper


    @addVacationFlag = (rows) ->
      resultRows = []
      for row in rows
        row.additionalClass ?= ''
        # TODO: combine flag functions
        if row.odd
          row.additionalClass += 'rowOdd '

        if row.first
          row.additionalClass += 'firstRow '

        if row.entry?.project is "urlaub"
          row.additionalClass += 'warning '
        resultRows.push row
      resultRows

    @addWeekendFlag = (rows) ->
      resultRows = []
      for row in rows
        row.additionalClass ?= ''
        # console.log row
        unless 0 < row.date.getDay() < 6
          row.additionalClass += 'dimmer active'
          row.weekend = true
        resultRows.push row

      resultRows

    @combineRows = (dateRows, sheetEntries) =>
      resultRows = []
      for row, i in dateRows
        even = i % 2 is 0

        entryRows = ({date: new Date(entry.date), entry: entry} for entry in sheetEntries when +(new Date(entry.date)) is +(row.date))

        if entryRows.length > 0
          entryRows = _.sortBy(entryRows, (n) -> n.projectName)
          firstRow = true

          for row in entryRows
            if firstRow
              row.first = true
              firstRow = false

            if even
              row.even = true
            else
              row.odd = true

            resultRows.push row
        else
          row.first = true
          if even
            row.even = true
          else
            row.odd = true
          resultRows.push row

      resultRows = @addVacationFlag(resultRows)
      @addWeekendFlag(resultRows)


    @dateRows = (begin, end) ->
      begin = new Date(begin)
      end = new Date(end)
      dayLength = end.getDate() - begin.getDate() + 1
      range = ({date: new Date(begin.getFullYear(), begin.getMonth(), day)} for day in [1..31] when day <= dayLength)

    @entryDuration = (entry) ->
      oneHour = 60 * 60 * 1000
      if entry? and entry.end? and entry.begin? and entry.intermission?
        beginTime = Date.parse(entry.begin)
        endTime = Date.parse(entry.end)
        (((endTime - beginTime) / oneHour)) - entry.intermission
      else
        0

    @workingHoursForProject:  (project, entries) =>
      projectName = project.name
      entries = _.filter entries, (entry, _) =>
        entry.project is projectName

      _.reduce entries,
      ((result, entry) =>
        result += @entryDuration(entry)),
      0

    @previousSheet = (sheet) ->


    @overtimeForDate = (entries, date) =>
      dayEntries = (entry for entry in entries when +(entry.date) is +date)

      if dayEntries.length > 0
        _.reduce dayEntries,
        ((result, entry) =>
          result + @entryDuration(entry)),
        -8
      else
        0

    @overallOvertime: (entries, sheet, dates) =>
      _.reduce dates
      , ((result, date) =>
        result += @overtimeForDate(entries, date))
      , 0


    @previousSheetKey: (sheet) =>
      monthDate = new Date(sheet.startDate)
      beforeMonthDate = new Date(monthDate.getFullYear(), monthDate.getMonth(), 0);
      beforeSheetKey = sheets.keyForSheet(beforeMonthDate.getFullYear(), beforeMonthDate.getMonth())


  Helper
