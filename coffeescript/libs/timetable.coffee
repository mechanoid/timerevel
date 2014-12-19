class DataTable
  tableTemplate: ->
    @$root = $('<table></table>')

  rowTemplate: (isWorkingDay) ->
    row = $('<tr></tr>')
    row.addClass('readonly') unless isWorkingDay
    row


  constructor: (@options) ->
    @$root = @tableTemplate()
    for i in [1..31]
      date = new Date(@options.year, @options.month, i)
      # @$root.append(@dataRow(date))


  dataRow: (date) ->
    enabled = (if 0 < date.getDay() < 6 then true else false)
    $row = @rowTemplate(date, enabled)
    $row.data('date', date)

  render: ->
    @$root


class Timetable
  constructor: (@$root) ->
    @options =
      year: @$root.data('year')
      month: @$root.data('month')

    @init()


  init: =>
    table = new DataTable(@options)
    @$root.append(table.render())
