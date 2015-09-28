command: "{ pmset -g batt; system_profiler SPPowerDataType | grep 'Cycle Count' | awk '{print $3}'; }",

refreshFrequency: 2000

style: """
  // Change bar height
  bar-height = 6px

  // Align contents left or right
  widget-align = left

  // Position this where you want
  top 355px
  left 25px

  // Statistics text settings
  color #fff
  font-family Helvetica Neue
  background rgba(#000, .5)
  padding 10px 10px 15px
  border-radius 5px

  .container
    width: 300px
    text-align: widget-align
    position: relative
    clear: both

  .widget-title
    text-align: widget-align

  .stats-container
    margin-bottom 5px
    border-collapse collapse

  td
    font-size: 14px
    font-weight: 300
    color: rgba(#fff, .9)
    text-shadow: 0 1px 0px rgba(#000, .7)
    text-align: widget-align

  .widget-title
    font-size 10px
    text-transform uppercase
    font-weight bold

  .label
    font-size 8px
    text-transform uppercase
    font-weight bold

  .bar-container
    width: 100%
    height: bar-height
    border-radius: bar-height
    float: widget-align
    clear: both
    background: rgba(#fff, .5)
    position: absolute
    margin-bottom: 5px

  .bar
    height: bar-height
    float: widget-align
    transition: width .2s ease-in-out

  .bar:first-child
    if widget-align == left
      border-radius: bar-height 0 0 bar-height
    else
      border-radius: 0 bar-height bar-height 0

  .bar:last-child
    if widget-align == right
      border-radius: bar-height 0 0 bar-height
    else
      border-radius: 0 bar-height bar-height 0

  .bar-battery-remaining.low
    background: rgba(#c00, .5)

  .bar-battery-remaining.medium
    background: rgba(#fc0, .5)

  .bar-battery-remaining.high
    background: rgba(#0bf, .5)

  .text-right
    text-align:right

  .text-center
    text-align:center
"""


render: -> """
  <div class="container">
    <div class="widget-title">Battery</div>
    <table class="stats-container" width="100%">
      <tr>
        <td class="stat"><span class="battery-remaining"></span></td>
        <td class="stat text-center"><span class="charge-cycle"></span></td>
        <td class="stat text-right"><span class="time-to-fullcharge"></span></td>
      </tr>
      <tr>
        <td class="label">Remaining</td>
        <td class="label text-center">Charge Cycle</td>
        <td class="label text-right">Time To Full Charge</td>
      </tr>
    </table>
    <div class="bar-container">
      <div class="bar bar-battery-remaining"></div>
    </div>
  </div>
"""

update: (output, domEl) ->
  updateStat = (battery_percent, time_to_fullcharge, charge_cycle, status) ->
    percent = battery_percent + "%"

    sel = 'battery-remaining';
    $(domEl).find(".#{sel}").text battery_percent + '%'
    $(domEl).find(".bar-#{sel}").css "width", percent
    $(domEl).find(".bar-#{sel}").addClass status

    sel = 'charge-cycle'
    $(domEl).find(".#{sel}").text charge_cycle

    sel = 'time-to-fullcharge'
    $(domEl).find(".#{sel}").text time_to_fullcharge

  #charge_cycle
  charge_cycle = output.match(/[0-9]+\n$/)[0];

  #battery_percent
  battery_percent = output.match(/[0-9]+%/)[0].replace(/[^0-9.]/g, '')
  parsed_battery_int = parseInt battery_percent

  #time for full charge
  time_to_fullcharge = output.match(/[0-9]+:[0-9]+ remaining/)[0].split(' remaining')[0];


  #figure out status
  status = 'high'
  if parsed_battery_int < 30
    status = 'low'
  else if parsed_battery_int < 60
    status = 'medium'

  updateStat parsed_battery_int, time_to_fullcharge, charge_cycle, status
