angular.module('SheetOverviewController', ['EntryService', 'uuid'])
.filter 'workingHoursForProject', (helper) ->
  helper.workingHoursForProject


.directive 'trOverview', ->
  {
    transclude: true
    templateUrl: 'views/sheet-overview'
  }

.controller 'overviewController', ($scope, entries, helper) ->
  setupOverviewController = (sheetEntryRows) ->
    $scope.sheetEntries = (row.doc for row in sheetEntryRows)
    projectNames = (entry.project for entry in $scope.sheetEntries)

    $scope.projects = _.uniq(projectNames)

    $scope.$apply()


  entries.all($scope.sheet, setupOverviewController)
