((window) ->
  $timetables = $('.timetable')
  new Timetable($(timetable).removeClass('timetable')) for timetable in $timetables

  true
)(window)
