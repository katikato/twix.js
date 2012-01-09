if typeof module != "undefined"
  moment = require("moment")
  assertEqual = require('assert').equal
  Twix = require("../../lib/twix")
else 
  moment = window.moment
  Twix = window.Twix
  assertEqual = (a, b) -> throw new Error("Found #{b}, expected #{a}") unless a == b

thisYear = (partial, time) -> 
  fullDate = "#{partial}/#{moment().year()}"
  fullDate += " #{time}" if time
  fullDate

describe "format()", ->

  test = (name, t) -> it name, ->
    twix = new Twix(t.start, t.end, t.allDay)
    assertEqual(t.result, twix.format(t.options))

  describe "simple ranges", ->
    test "different year, different day shows everything"
      start: "5/25/1982 5:30 AM"
      end: "5/26/1983 3:30 PM"
      result: 'May 25, 1982, 5:30 AM - May 26, 1983, 3:30 PM'

    test "this year, different day skips year",
      start: thisYear("5/25", "5:30 AM")
      end: thisYear("5/26", "3:30 PM")
      result: 'May 25, 5:30 AM - May 26, 3:30 PM'

    test "same day, different times shows date once",
      start: "5/25/1982 5:30 AM"
      end: "5/25/1982 3:30 PM"
      result: 'May 25, 1982, 5:30 AM - 3:30 PM'

    test "same day, different times, same meridian shows date and meridiem once",
      start: "5/25/1982 5:30 AM"
      end: "5/25/1982 6:30 AM"
      result: 'May 25, 1982, 5:30 - 6:30 AM'

  describe "rounded times", ->
    test "round hour doesn't show :00",
      start: "5/25/1982 5:00 AM"
      end: "5/25/1982 7:00 AM"
      result: "May 25, 1982, 5 - 7 AM"

    test "mixed times still shows :30",
      start: "5/25/1982 5:00 AM"
      end: "5/25/1982 5:30 AM"
      result: "May 25, 1982, 5 - 5:30 AM"

  describe "implicit minutes", ->
    test "still shows the :00",
      start: thisYear "5/25", "5:00 AM"
      end: thisYear "5/25", "7:00 AM"
      options: {implicitMinutes: false}
      result: "May 25, 5:00 - 7:00 AM"

  describe "all day events", ->

    test "one day has no range",
      start: "5/25/2010"
      end: "5/25/2010"
      allDay: true
      result: "May 25, 2010"  

    test "same month says month on one side",
      start: thisYear("5/25")
      end: thisYear("5/26")
      allDay: true
      result: "May 25 - 26"
    
    test "different month shows both",
      start: thisYear("5/25")
      end: thisYear("6/1")
      allDay: true
      result: "May 25 - Jun 1"

    test "explicit year shows the year once", 
      start: "5/25/1982"
      end: "5/26/1982"
      allDay: true, 
      result: "May 25 - 26, 1982"

    test "different year shows the year twice", 
      start: "5/25/1982"
      end: "5/25/1983"
      allDay: true
      result: "May 25, 1982 - May 25, 1983"

    test "different year different month shows the month at the end"
      start: "5/25/1982"
      end: "6/1/1983"
      allDay: true
      result: "May 25, 1982 - Jun 1, 1983"

  describe "no single dates", ->
    test "shouldn't show dates for intraday", 
      start: "5/25/2010 5:30 AM"
      end: "5/25/2010 6:30 AM"
      options: {showDate: false}
      result: "5:30 - 6:30 AM"

    test "should show the dates for multiday",
      start: thisYear "5/25", "5:30 AM"
      end: thisYear "5/27", "6:30 AM"
      options: {showDate : false}
      result: "May 25, 5:30 AM - May 27, 6:30 AM"

    test "should just say 'all day' for all day events",
      start: thisYear("5/25")
      end: thisYear("5/25")
      options: {showDate : false}
      allDay: true
      result: "All day"

  describe "ungroup meridiems", ->
    test "should put meridiems on both sides",
      start: thisYear "5/25", "5:30 AM"
      end: thisYear "5/25", "7:30 AM"
      options: {groupMeridiems: false}
      result: "May 25, 5:30 AM - 7:30 AM"

  describe "no meridiem spaces", ->
    test "should skip the meridiem space"
      start: thisYear "5/25", "5:30 AM"
      end: thisYear "5/25", "7:30 AM"
      options: {spaceBeforeMeridiem: false, groupMeridiems: false}
      result: "May 25, 5:30AM - 7:30AM"

  describe "24 hours", ->
    test "shouldn't show meridians"
      start: thisYear "5/25", "5:30 AM"
      end: thisYear "5/25", "7:30 PM"
      options: {twentyFourHour: true},
      result: "May 25, 5:30 - 19:30"

describe "sameYear()", ->

  it "returns true if they're the same year", ->
    assertEqual(true, new Twix("5/25/1982", "10/14/1982").sameYear())

  it "returns false if they're different years", ->
    assertEqual(false, new Twix("5/25/1982", "10/14/1983").sameYear())

describe "sameDay()", ->

  it "returns true if they're the same day", ->
    assertEqual(true, new Twix("5/25/1982 5:30 AM", "5/25/1982 7:30 PM").sameDay())

  it "returns false if they're different days day", ->
    assertEqual(false, new Twix("5/25/1982 5:30 AM", "5/26/1982 7:30 PM").sameDay())

  it "returns true they're in different UTC days but the same local days", ->
    assertEqual(true, new Twix("5/25/1982 5:30 AM", "5/25/1982 11:30 PM").sameDay())