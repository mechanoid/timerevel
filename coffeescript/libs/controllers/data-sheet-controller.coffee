angular.module('DataSheetController', [])

.directive 'trSheet', ($timeout) ->
  {
    transclude: true
    link: (scope, elem, attrs) ->
      scope.$on 'sheetsLoaded', ->
        $timeout ->
          $('.tabular.menu .item').off 'click'
          $('.tabular.menu .item').on 'click', (e) ->
            target = $(e.target)
            target.parents('.menu').find('.item').removeClass('active')
            target.parent().addClass('active')
            $.tab('change tab', target.data('tab'))
        , 0
        , false

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
  currentMonth = new Date().getMonth()

  sheets.all()
  .then (response) ->
    sheets = (row.doc for row in response.rows)


    $scope.sheets = sheets
    $scope.menuEntries = []

    for sheet in $scope.sheets
      sheetMonth = new Date(sheet.startDate).getMonth()
      monthMenuEntry = { name: sheet.name }

      if sheetMonth is currentMonth
        sheet.currentMonthClass = "active"
        monthMenuEntry.activeMonthClass = "active"

      $scope.menuEntries.push monthMenuEntry

    $scope.$apply()
    $scope.$broadcast('sheetsLoaded')
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
