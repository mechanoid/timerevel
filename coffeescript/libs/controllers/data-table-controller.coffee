angular.module('DataTableController', [])

.directive 'trTable', (sheets) ->
  {
    transclude: true
    # link: (scope, elem, attrs) ->
    templateUrl: 'views/data-table'
  }

.controller 'tableController', ($scope) ->
  dateRows = (begin, end) ->
    begin = new Date(begin)
    end = new Date(end)
    dayLength = end.getDate() - begin.getDate()
    range = ({date: new Date(begin.getFullYear(), begin.getMonth(), day)} for day in [1..31] when day < dayLength)


  combineRows = (dateRows, entries) ->
    resultRows = []
    for row in dateRows
      entryRows = ({date: entry.date, entry: entry} for entry in entries when +(new Date(entry.date)) is +(row.date))

      if entryRows.length > 0
        resultRows.push row for row in entryRows
      else
        resultRows.push row
    resultRows

  # console.log $scope.sheet
  entries = [
    project: "Fubar"
    date: new Date(2015, 0, 1)
  ,
    project: "Fabula"
    date: new Date(2015, 0, 1)
  ]

  currentDateRows = dateRows($scope.sheet.startDate, $scope.sheet.endDate)

  $scope.combinedRows = combineRows(currentDateRows, entries)
