angular.module('dataTableController', [])

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
    range = (new Date(begin.getFullYear(), begin.getMonth(), day) for day in [1..31] when day < dayLength)


  combineRows = (dateRows, entries) ->
    resultRows = []
    for date in dateRows
      # entryRows = (entry for entry in entries when new Date(entry.date) is date)
      for entry in entries
        console.log +(new Date(entry.date)) is +service/PrivateCustomerRegistrationProcessService.groovy(date)
      # console.log entryRows

  entries = [
    project: "Fubar"
    date: new Date(2015, 0, 1)
  ,
    project: "Fabula"
    date: new Date(2015, 0, 1)
  ]

  currentDateRows = dateRows($scope.sheet.startDate, $scope.sheet.endDate)
  combinedRows = combineRows(currentDateRows, entries)

  $scope.entries = entries
  $scope.rows = combinedRows
