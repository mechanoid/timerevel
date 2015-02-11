angular.module('SheetOverviewController', ['EntryService', 'uuid'])
.filter 'workingHoursForProject', (helper) ->
  helper.workingHoursForProject

.filter 'asOvertime', ->
  (overtime) ->
    if parseFloat(overtime) > 0 then "+#{overtime}" else overtime




.directive 'trOverview', ->
  {
    transclude: true
    templateUrl: 'views/sheet-overview'
  }

.controller 'overviewController', ($rootScope, $scope, entries, sheets, helper, db) ->
  overallOvertime = ->
    dateRows = helper.dateRows($scope.sheet.startDate, $scope.sheet.endDate)
    dates = (row.date for row in dateRows)

    helper.overallOvertime($scope.sheetEntries, $scope.sheet, dates)

  overallHours = ->
    _.reduce $scope.sheetEntries
    , (result, entry) ->
      result += helper.entryDuration(entry)
    , 0

  projects = ->
    projectNames = _.uniq(entry.project for entry in $scope.sheetEntries)
    ({name: projectName} for projectName in projectNames)

  setupSummaries = (sheetEntryRows) ->
    $scope.projects = projects()
    $scope.sheet.overtime = $scope.overtimeSum = overallOvertime()
    $scope.hoursSum = overallHours()
    # TODO: is this update necessary, does it work already and it is legacy? ??
    # sheets.update($scope.sheet)

  setupOverviewController = (sheetEntryRows) ->
    $scope.sheetEntries = (row.doc for row in sheetEntryRows)
    setupSummaries()

    $rootScope.$on "entries-added-to-#{$scope.sheet.name}", (_, sheetEntries) ->
      $scope.sheetEntries = sheetEntries
      setupSummaries(sheetEntryRows)

  entries.all($scope.sheet).then setupOverviewController
