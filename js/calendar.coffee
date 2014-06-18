$ () -> # execute when DOM is ready

  $('.addPhase input[type=submit]').tooltip({
    title: 'Den Tag kannst du gleich auswählen'
    placement: 'right'
  }).tooltip 'show'

  # form validation
  timeChecks = {
    hour:
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
    $inputs = $('#addPhaseForm').find 'input:not(.btn)'
    values = {}
    $inputs.each () -> # for some reason won't fire for the time inputs
      input = $ @
      name = input.attr 'name'
      type = input.attr 'type'
      value = input.val()
      values[name] = value
      if type.toLowerCase() is 'number'
        values[name] = parseInt value

#    timeFrom = moment {
#      hour: values['from-hour']
#      minute: values['from-minute']
#    }
#    timeUntil = moment {
#      hour: values['until-hour']
#      minute: values['until-minute']
#    }
    learningPhase = { # use the element's text as the event title
      title: values['name']
      start:
        hour: values['from-hours']
        minute: values['from-minutes']
      end:
        hour: values['until-hours']
        minute: values['until-minutes']
    }

    # create new phase element
    added = $ '<div></div>'
    added.data 'learningPhase', learningPhase
    dummy = $('#phase-dummy').html()
    dummy = dummy.replace '%NAME%', values['name']
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
      originalEventObject = $(this).data('learningPhase')
      
      # we need to copy it, so that multiple events don't have a reference to the same object
      copiedEventObject = $.extend({}, originalEventObject)

      # assign it the date that was reported
      copiedEventObject.start = date

      # render the event on the calendar
      # the last `true` argument determines if the event "sticks" (http://arshaw.com/fullcalendar/docs/event_rendering/renderEvent/)
      $('#calendar').fullCalendar('renderEvent', copiedEventObject, true)
  })









