saveHostnames = () ->
  chrome.runtime.sendMessage {hostnames: getList(), type: 'hostnames'}

deleteHostname = () ->
  $(this).closest('.hostNameWrapper').fadeOut () ->
    $(this).remove()

append = () ->
  $('#inputTemplate').clone().removeAttr('id').appendTo('#hostnameInput').fadeIn()

getList = () ->
  hosts = []
  $('#hostnames input').each () ->
    host = $(this).val()
    if host? and host.length > 0
      hosts.push host
  return hosts

$ () ->

  $('#startPhase').click () ->
    chrome.runtime.sendMessage {type: 'startLearning'}

  $('#hostnames').submit (e) -> e.preventDefault()
  $('#hostnames button[type=submit]').click saveHostnames
  $('#hostnames').on 'click', '.hostnameRemover', deleteHostname
  $('#hostnames').on 'click', '.hostnameRemover span', deleteHostname
  $('#addHostname').click append