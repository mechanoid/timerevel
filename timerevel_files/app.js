var DayEntry;

DayEntry = (function() {
  DayEntry.entriesForMonth = function(sheet) {
    var day, ref, _i, _results;
    ref = new Date(sheet.year, sheet.month, 0);
    _results = [];
    for (day = _i = 1; _i <= 31; day = ++_i) {
      if (day <= ref.getDate()) {
        _results.push(new DayEntry(sheet, day));
      }
    }
    return _results;
  };

  function DayEntry(sheet, day) {
    var _ref;
    this.sheet = sheet;
    this.day = day;
    this.date = new Date(this.sheet.year, this.sheet.month - 1, this.day);
    this.id = "" + this.sheet.year + "_" + this.sheet.month + "_" + this.day;
    if ((_ref = this.sheet) != null ? _ref.entries[this.id] : void 0) {
      this.sheetEntry = this.sheet.entries[this.id];
    }
  }

  return DayEntry;

})();

angular.module('dataSheetController', []).directive('trSheet', function() {
  return {
    transclude: true,
    link: function(scope, elem, attrs) {
      return scope.sheet.setMonth(attrs.month);
    },
    templateUrl: 'angular/sheet'
  };
}).directive('trDataTable', function($rootScope) {
  return {
    transclude: true,
    link: function(scope, elem, attrs) {
      scope.entries = DayEntry.entriesForMonth(scope.sheet);
      return scope.$watch('sheet.entries', function() {
        var entry, _, _ref, _results;
        _ref = arguments[0];
        _results = [];
        for (_ in _ref) {
          entry = _ref[_];
          if ((entry.begin != null) && (entry.end != null)) {
            _results.push(entry.duration = (entry.end - entry.begin) / 3600 / 1000);
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }, true);
    },
    templateUrl: 'angular/data-table'
  };
}).controller('sheetController', function($rootScope, $scope) {
  $scope.sheet = {
    monthName: "Januar",
    year: $rootScope.timerevel.year,
    entries: {}
  };
  $scope.sheet.setMonth = function(month) {
    return $scope.sheet.month = month;
  };
  return $scope.$watch('sheet', function() {
    return $rootScope.timerevel.sheets[$scope.sheet.month] = $scope.sheet;
  }, true);
});

(function(window) {
  var app;
  app = angular.module('timerevel', ['dataSheetController']);
  app.controller('timerevelController', function($rootScope) {
    return $rootScope.timerevel = {
      version: '0.0.1',
      year: 2014,
      sheets: {}
    };
  });
  return true;
})(window);
