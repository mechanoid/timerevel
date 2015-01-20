((window) ->
  app = angular.module 'timerevel', [
    'DbService'
    'SheetService'
    'EntryService'
    'DataSheetController'
    'DataTableController'
  ]

  app.controller 'timerevelController', ($scope, $rootScope) ->
    $rootScope.timerevel =
      version: '0.0.1'
      year: 2015

  true
)(window)
