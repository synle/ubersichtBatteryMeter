command:"pmset -g batt | grep \"%\" | awk 'BEGINN { FS = \";\" };{ print $3,$2 }' | sed -e 's/-I/I/' -e 's/-0//' -e 's/;//' -e 's/;//'",

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
"""


render: -> """
  <div class="container">
    <div class="widget-title">Battery</div>
    <table class="stats-container" width="100%">
      <tr>
        <td class="stat"><span class="battery-remaining"></span></td>
      </tr>
      <tr>
        <td class="label">Remaining</td>
      </tr>
    </table>
    <div class="bar-container">
      <div class="bar bar-battery-remaining"></div>
    </div>
  </div>
"""

update: (output, domEl) ->
  updateStat = (sel, usage, status) ->
    percent = usage + "%"
    # $(domEl).find(".#{sel}").text usage + '%'
    $(domEl).find(".#{sel}").text usage + '%'
    $(domEl).find(".bar-#{sel}").css "width", percent
    $(domEl).find(".bar-#{sel}").addClass status

  battery_percent = output.replace(/[^0-9.]/g, '')
  parsed_battery_int = parseInt(battery_percent)

  status = 'high'
  if(parsed_battery_int < 30)
    status = 'low'
  else if(parsed_battery_int < 60)
    status = 'medium'

  updateStat 'battery-remaining', parsed_battery_int, status
