angular.module('SheetOverviewController', ['EntryService', 'uuid'])
.filter 'workingHoursForProject', (helper) ->
  helper.workingHoursForProject


.directive 'trOverview', ->
  {
    transclude: true
    templateUrl: 'views/sheet-overview'
  }

.controller 'overviewController', ($scope, entries, helper) ->
  # entries.all($scope.sheet)
  # .then (response) ->
  #   $scope.entries = (row.doc for row in response.rows)
  #   console.log $scope.entries
  #   projectNames = (entry.project for entry in $scope.entries)
  #
  #   $scope.projects = _.uniq(projectNames)
  #
  #   $scope.$apply()
