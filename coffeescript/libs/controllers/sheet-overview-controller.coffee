angular.module('SheetOverviewController', ['EntryService', 'uuid'])
.filter 'workingHoursForProject', (helper) ->
  helper.workingHoursForProject


.directive 'trOverview', ->
  {
    transclude: true
    templateUrl: 'views/sheet-overview'
  }

.controller 'overviewController', ($scope, entries, helper, db) ->
  setupOverviewController = (sheetEntryRows) ->
    $scope.sheetEntries = (row.doc for row in sheetEntryRows)
    projectNames = _.uniq(entry.project for entry in $scope.sheetEntries)
    $scope.projects = []
    for projectName in projectNames
      $scope.projects.push {name: projectName}

    $scope.hoursSum = _.reduce $scope.sheetEntries
    , (result, entry) ->
      result += helper.entryDuration(entry)
    , 0


    $scope.$apply()

  entries.all($scope.sheet, setupOverviewController)
  # db.changes(live: true, since: 'now').on "complete", ->
  #   console.log "CHANGED"
