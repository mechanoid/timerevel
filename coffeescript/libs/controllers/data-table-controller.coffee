angular.module('DataTableController', ['EntryService', 'uuid'])
.filter 'workingHours', ->
  (entry) ->
    oneHour = 60 * 60 * 1000

    if entry.end? and entry.begin? and entry.break?
      (((entry.end.getTime() - entry.begin.getTime()) / oneHour))
    else
      0


.directive 'trTable', (sheets) ->
  {
    transclude: true
    # link: (scope, elem, attrs) ->
    templateUrl: 'views/data-table'
  }

.controller 'tableController', ($scope, entries) ->
  dateRows = (begin, end) ->
    begin = new Date(begin)
    end = new Date(end)
    dayLength = end.getDate() - begin.getDate()
    range = ({date: new Date(begin.getFullYear(), begin.getMonth(), day)} for day in [1..31] when day < dayLength)

  addWeekendFlag = (rows) ->
    resultRows = []
    for row in rows

      unless 0 < row.date.getDay() < 6
        row.weekend = true
      resultRows.push row

    resultRows

  combineRows = (dateRows, entries) ->
    resultRows = []
    for row in dateRows
      entryRows = ({date: entry.date, entry: entry} for entry in entries when +(new Date(entry.date)) is +(row.date))

      if entryRows.length > 0
        firstRow = true
        for row in entryRows
          if firstRow
            row.first = true
            firstRow = false

          resultRows.push row
      else
        row.first = true
        resultRows.push row

    addWeekendFlag(resultRows)

  # console.log $scope.sheet
  # sheetEntries = [
  #   project: "Fubar"
  #   date: new Date(2015, 0, 1)
  # ,
  #   project: "Fabula"
  #   date: new Date(2015, 0, 1)
  # ]
  entries.all($scope.sheet)
  .then (response) ->
    $scope.sheetEntries = (row.doc for row in response.rows)
    currentDateRows = dateRows($scope.sheet.startDate, $scope.sheet.endDate)

    $scope.combinedRows = combineRows(currentDateRows, $scope.sheetEntries)
    $scope.$watch "sheetEntries",
    ((after, before) ->
      entries.update(elem) for i, elem of after when _.isEqual(elem, before[i]) isnt true),
    true

    $scope.newEntry = (row) =>
      $scope.sheetEntries.push(entries.new(row.date))
      $scope.combinedRows = combineRows(currentDateRows, $scope.sheetEntries)

    $scope.deleteEntry = (entry) =>
      entries.delete(entry)
      _.remove($scope.sheetEntries, (current) -> current.key is entry.key)
      $scope.combinedRows = combineRows(currentDateRows, $scope.sheetEntries)

    $scope.$apply()
