learnPhases = []
learnSessions = []

chrome.storage.local.get ['learnPhases', 'learnSessions'], (items) ->
  learnPhases = items.learnPhases || []
  learnSessions = items.learnSessions || []
  console.log 'loaded', learnPhases, learnSessions

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

    # create new phase element
    added = $ '<div></div>'
    added.data 'learningPhase', learningPhase
    learnPhases.push learningPhase
    dummy = $('#phase-dummy').html()
    dummy = dummy.replace '%NAME%', learningPhase.title
    added.html dummy
    added.appendTo 'body'

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

  makeDraggable = (element) ->
    $(element).draggable {
      zIndex: 999,
      revert: true,      # will cause the event to go back to its
      revertDuration: 0  #  original position after the drag
    }

  # initizalize demo drag and drop
  $('#external-events div.external-event').children().each () ->
    # create an Event Object (http://arshaw.com/fullcalendar/docs/event_data/Event_Object/)
    # it doesn't need to have a start or end

    # make the event draggable using jQuery UI
    makeDraggable $(this)

  saveAll = () ->
    chrome.storage.local.set {
      'learnPhases': learnPhases
      'learnSessions': learnSessions
    }, () ->
      console.log 'saved!'

  $('#calendar').fullCalendar({
    header: {
      left: 'prev,next today'
      center: 'title'
      right: 'month,agendaWeek'
    }
    editable: true
    droppable: true # this allows things to be dropped onto the calendar !!!
    drop: (date) -> # this function is called when something is dropped
      # retrieve the dropped element's stored Event Object
      learningPhase = $(this).data('learningPhase')
      
      # we need to copy it, so that multiple events don't have a reference to the same object
      event = $.extend {}, learningPhase

      # assign it the date that was reported
      start = date.clone()
      start.set 'minutes', learningPhase.start.minutes
      start.set 'h', learningPhase.start.hours
      event.start = start

      event.end = date.clone()
      event.end.set 'h', learningPhase.end.hours
      event.end.set 'minutes', learningPhase.end.minutes

      event.allDay = false

      learnSessions.push event
      saveAll()
      # render the event on the calendar
      # the last `true` argument determines if the event "sticks" (http://arshaw.com/fullcalendar/docs/event_rendering/renderEvent/)
      $('#calendar').fullCalendar 'renderEvent', event, true
  })









