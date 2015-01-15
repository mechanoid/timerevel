angular.module('dataSheetController', [])

.directive 'trSheet', ->
  {
    transclude: true
    link: (scope, elem, attrs) ->
    templateUrl: 'views/sheet'
  }

.directive 'trDataTable', ($rootScope) ->

  {
    transclude: true
    link: (scope, elem, attrs) ->

    templateUrl: 'views/data-table'
  }


.controller 'sheetController', ($rootScope, $scope, sheets) ->

  sheets.initializeSheetsForYear($rootScope.timerevel.year)

  sheets.all()
  .then (response) ->
    $scope.sheets = (row.doc for row in response.rows)
    $scope.$watch 'sheets'
    , (after, before) ->
      sheets.update(elem) for i, elem of after when _.isEqual(elem, before[i]) isnt true
    , true

    $scope.$apply()
  .catch ->
    $scope.sheetRows = []



# # $q EXAMPLE
# $q.all([
#   pp.getScore('1'),
#   pp.getScore('2'),
#   pp.getScore('3')
# ]).then(function(res) {
#     $scope.score['1'] = res[0];
#     $scope.score['2'] = res[1];
#     $scope.score['3'] = res[2]
#   });
