angular.module('SheetOverviewController', ['EntryService', 'uuid'])
.filter 'workingHoursForProject', (helper) ->
  helper.workingHoursForProject


.directive 'trOverview', ->
  {
    transclude: true
    templateUrl: 'views/sheet-overview'
  }

.controller 'overviewController', ($rootScope, $scope, entries, sheets, helper, db) ->
  overallOvertime = ->
    dateRows = helper.dateRows($scope.sheet.startDate, $scope.sheet.endDate)
    overtime = _.reduce dateRows
    , (result, row) ->
      result += helper.overtimeForDate($scope.sheetEntries, row.date)
    , 0
    $scope.sheet.overtime = overtime
    # sheets.update($scope.sheet)
    overtime

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
    $scope.overtimeSum = overallOvertime()
    $scope.hoursSum = overallHours()

  setupOverviewController = (sheetEntryRows) ->
    $scope.sheetEntries = (row.doc for row in sheetEntryRows)
    setupSummaries()

    $rootScope.$on "entries-added-to-#{$scope.sheet.name}", (_, sheetEntries) ->
      $scope.sheetEntries = sheetEntries
      setupSummaries(sheetEntryRows)

    $scope.$apply()

  entries.all($scope.sheet, setupOverviewController)
  # db.changes(live: true, since: 'now').on "complete", ->
  #   console.log "CHANGED"
