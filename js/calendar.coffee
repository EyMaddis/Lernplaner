# VERALTET!
learnPhases = []
learnSessions = []

window.getCurrentPhase = (callback) ->
  chrome.storage.local.get ['learnPhases', 'learnSessions'], (items) ->
    learnPhases = items.learnPhases || []
    learnSessions = items.learnSessions || []

    now = moment()
    for session in learnSessions # TODO allDay
      console.log moment(session.start).unix()
      console.log session, now.isAfter(moment(session.start)), now.isBefore(moment(session.end))

fullcalendar = null
initializeCalendar = () ->

  fullcalendar = $('#calendar').fullCalendar({
    header: {
      left: 'prev,next today'
      center: 'title'
      right: 'month,agendaWeek'
    }
    events: learnSessions
    editable: true
    droppable: true # this allows things to be dropped onto the calendar !!!
    drop: (date) -> # this function is called when something is dropped
      # retrieve the dropped element's stored Event Object
      learningPhase = $(this).data('learningPhase')

      # we need to copy it, so that multiple events don't have a reference to the same object
      event = sessionFromPhase date, learningPhase
      learnSessions.push $.extend({}, event) if event?
      saveAll()
      # render the event on the calendar
      # the last `true` argument determines if the event "sticks" (http://arshaw.com/fullcalendar/docs/event_rendering/renderEvent/)
      $('#calendar').fullCalendar 'renderEvent', event, true
  })

sessionFromPhase = (date, phase) ->
  event = $.extend {}, phase

  # assign it the date that was reported
  start = date.clone()
  start.set 'minutes', phase.start.minutes
  start.set 'h', phase.start.hours
  event.start = moment start

  end = date.clone()
  end.set 'h', phase.end.hours
  end.set 'minutes', phase.end.minutes
  event.end = moment end
  event.allDay = false
  return event

createPhase = (data) ->
  # create new phase element
  return unless data?
  added = $ '<div></div>'
  learnPhases.push data
  dummy = $('#phase-dummy').html()
  dummy = dummy.replace '%NAME%', " #{data.title} - #{data.start.hours}:#{data.start.minutes}"
  added.html dummy
  added.appendTo '.external-event'
  makeDraggable added
  added.data 'learningPhase', data

saveAll = () ->
  sessions = []
  for session in learnSessions
    sessions.push {
      title: session.title
      isAllDay: session.isAllDay
      start: session.start.unix()
      end: session.end.unix()
    }
  phases = []
  for phase in learnPhases
    phases.push phase if phase?
  chrome.storage.local.set {
    'learnPhases': learnPhases
    'learnSessions': sessions
  }, () ->
    console.log 'saved!'

makeDraggable = (element) ->
  $(element).draggable {
    zIndex: 999,
    revert: true,      # will cause the event to go back to its
    revertDuration: 0  #  original position after the drag
  }
$ () -> # execute when DOM is ready

  $('.addPhase input[type=submit]').tooltip({
    title: 'Den Tag kannst du gleich auswählen'
    placement: 'right'
  }).tooltip 'show'

  # form validation
  timeChecks = {
    hours:
      format: ['HH','H']
      error: 'Nicht zwischen 0 und 24'
    minute:
      format: ['mm','m']
      error: 'Nicht zwischen 0 und 60'
  }

  # catch form submit
  $form = $ '#addPhaseForm'
  $form.on 'submit', (event) ->
    event.preventDefault()

    learningPhase = { # use the element's text as the event title
      title: $('#name').val()
      start:
        hours: parseInt $('#from-hours').val()
        minutes: parseInt $('#from-minutes').val()
      end:
        hours: parseInt $('#until-hours').val()
        minutes: parseInt $('#until-minutes').val()
    }
    unless learningPhase?
      console.log 'null dragged!', learningPhase
      return
    added = createPhase(learningPhase)

    # flowing above the button
    buttonOffset = $('#addPhaseBtn').offset()
    added.css {
      position: 'fixed'
      left: buttonOffset.left
      top: buttonOffset.top
    }

    # let it fly to the target position
    targetOffset = $('.external-event').offset()
    added.animate({
      left: targetOffset.left
      top: targetOffset.top
    }, 1000, () ->
      added.css {
        position: 'relative'
        top: 'auto'
        left: 'auto'
      }
      makeDraggable added.appendTo('.external-event').hide().slideDown('slow')
    )
    saveAll()




chrome.storage.local.get ['learnPhases', 'learnSessions'], (items) ->
  learnPhases = items.learnPhases || []
  sessions = items.learnSessions || []
  console.log 'loaded', learnPhases, learnSessions

  for phase in learnPhases
    createPhase phase

  for session in sessions
    console.log session
    learnSessions.push {
      title: session.title
      isAllDay: session.isAllDay
      start: moment(session.start, 'X')
      end: moment(session.end, 'X')
    }
  initializeCalendar()


  # initizalize demo drag and drop
#  $('#external-events div.external-event').children().each () ->
#    # create an Event Object (http://arshaw.com/fullcalendar/docs/event_data/Event_Object/)
#    # it doesn't need to have a start or end
#
#    # make the event draggable using jQuery UI
#    makeDraggable $(this)











