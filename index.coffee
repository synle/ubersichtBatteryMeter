command: "{ pmset -g batt; system_profiler SPPowerDataType | grep 'Cycle Count' | awk '{print $3}'; }",

refreshFrequency: 5000

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
        <td class="stat text-center"><span class="power-source"></span></td>
        <td class="stat text-right"><span class="time-to-fullcharge"></span></td>
      </tr>
      <tr>
        <td class="label">Remaining</td>
        <td class="label text-center">Charge Cycle</td>
        <td class="label text-center">Power Source</td>
        <td class="label text-right charge-status-label"></td>
      </tr>
    </table>
    <div class="bar-container">
      <div class="bar bar-battery-remaining"></div>
    </div>
  </div>
"""

update: (output, domEl) ->
  updateStat = (battery_percent, charge_time_delta, charge_cycle, charge_status, power_source) ->
    percent = battery_percent + "%"

    #figure out status_text
    status_text = 'high'
    if parsed_battery_int < 30
      status_text = 'low'
    else if parsed_battery_int < 60
      status_text = 'medium'

    sel = '.battery-remaining';
    $(domEl).find("#{sel}").text battery_percent + '%'

    sel = '.bar-battery-remaining'
    $(domEl).find(sel).css('width', percent)
      .addClass status_text

    sel = '.charge-cycle'
    $(domEl).find("#{sel}").text charge_cycle

    sel = '.time-to-fullcharge'
    $(domEl).find("#{sel}").text charge_time_delta

    sel = '.charge-status-label'
    $(domEl).find("#{sel}").text charge_status

    sel = '.power-source'
    $(domEl).find("#{sel}").text power_source


  #charge_cycle
  charge_cycle = output.match(/[0-9]+\n$/)[0];

  #battery_percent
  battery_percent = output.match(/[0-9]+%/)[0].replace(/[^0-9.]/g, '')
  parsed_battery_int = parseInt battery_percent

  #time for full charge
  if output.indexOf('discharging') >= 0
    charge_status = 'Remaining Time'
  else
    charge_status = 'Time until Full'

  try
    charge_time_delta = output.match(/[0-9]+:[0-9]+ remaining/)[0].split(' remaining')[0]
  catch ex
    charge_time_delta = 'no estimate'

  #power Source
  if output.indexOf('AC') >= 0
    power_source = 'AC'
  else
    power_source = 'Battery'

  updateStat parsed_battery_int, charge_time_delta, charge_cycle, charge_status, power_source
