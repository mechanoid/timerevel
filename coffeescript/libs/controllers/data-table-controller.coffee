angular.module('DataTableController', ['EntryService', 'HelperService'])
.filter 'workingHours', (helper) -> helper.entryDuration
.filter 'monthlyHours', (helper) ->
  # (sheetEntries) ->
  #   _.reduce sheetEntries,
  #   ((result, entry) ->
  #     result += helper.entryDuration(entry)),
  #   0
  -> 0
.filter 'overtime', (helper) -> helper.overtimeForDate

.filter 'overallOvertime', (helper) -> helper.overallOvertime
# .filter 'previousOvertime', (helper) -> helper.previousOvertime

.directive 'trTable', ($timeout) ->
  {
    transclude: true
    link: (scope, elem, attrs) ->
      $timeout ->
        $('.ui.checkbox').checkbox()
      , 1000
      , false
    templateUrl: 'views/data-table'
  }

.controller 'tableController', ($rootScope, $scope, entries, sheets, helper) ->
  notifySheetEntryChanges = (sheetEntries) ->
    $rootScope.$broadcast("entries-added-to-#{$scope.sheet.name}", sheetEntries)

  setupTableController = (sheetEntryRows) ->
    $scope.sheetEntries = (row.doc for row in sheetEntryRows)
    currentDateRows = helper.dateRows($scope.sheet.startDate, $scope.sheet.endDate)
    $scope.dates = _.map(currentDateRows, (row) -> row.date)

    $scope.combinedRows = helper.combineRows(currentDateRows, $scope.sheetEntries)

    $scope.newEntry = (row) ->
      entry = entries.new($scope.sheet, row.date)
      $scope.sheetEntries.push(entry)
      notifySheetEntryChanges($scope.sheetEntries)
      $scope.combinedRows = helper.combineRows(currentDateRows, $scope.sheetEntries)

    $scope.copyEntry = (entry) ->
      $scope.copiedEntry = _.pick entry, ['project', 'begin', 'end', 'intermission', 'notice', 'tm']

    $scope.pasteEntry = (row) ->
      copy = $scope.copiedEntry
      entry = entries.new($scope.sheet, row.date, copy.project, copy.begin, copy.end, copy.intermission, copy.notice, copy.tm)
      $scope.sheetEntries.push(entry)
      notifySheetEntryChanges($scope.sheetEntries)
      $scope.combinedRows = helper.combineRows(currentDateRows, $scope.sheetEntries)
      $scope.copiedEntry = null


    $scope.deleteEntry = (entry) ->
      entries.delete(entry)
      _.remove($scope.sheetEntries, (current) -> current.key is entry.key)
      notifySheetEntryChanges($scope.sheetEntries)
      $scope.combinedRows = helper.combineRows(currentDateRows, $scope.sheetEntries)

    $scope.$watch "sheetEntries",
    ((after, before) ->
      notifySheetEntryChanges($scope.sheetEntries)
      entries.update(elem) for i, elem of after when _.isEqual(elem, before[i]) isnt true),
    true
    $scope.$apply()

  entries.all($scope.sheet, setupTableController)

  sheets.findByKey(helper.previousSheetKey($scope.sheet)).then (previousSheet) ->
    $scope.previousOvertime = previousSheet?.overtime
    $scope.$apply()
