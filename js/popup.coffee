load = () ->
  chrome.storage.local.get ['hostnames'], (loaded) ->
    console.log 'loaded', loaded
    for hostname in loaded.hostnames
      append(hostname)

saveHostnames = () ->
  list = getList()
  chrome.runtime.sendMessage {hostnames: list, type: 'hostnames'}
  chrome.storage.local.set {hostnames: list}, () ->
    console.log 'saved to local storage: ', list

deleteHostname = () ->
  $(this).closest('.hostNameWrapper').fadeOut () ->
    $(this).remove()
    saveHostnames()

append = (val) ->
  cloned = $('#inputTemplate').clone().removeAttr('id').appendTo('#hostnameInput')
  console.log arguments[0]
  if val
    cloned.find('input').val val
  cloned.fadeIn()

getList = () ->
  hosts = []
  $('#hostnames input').each () ->
    host = $(this).val()
    if host? and host.length > 0
      hosts.push host
  return hosts

chrome.runtime.onMessage.addListener (request) ->
  console.log request

chrome.runtime.sendMessage {
  type: 'openPopup'
}
$ () ->
  load()
  $(window).on 'beforeunload', () ->
    saveHostnames()

  $('#startPhase').click () ->
    chrome.runtime.sendMessage {type: 'startLearning'}

  $('#hostnames').submit (e) -> e.preventDefault()
  $('#hostnames button[type=submit]').click saveHostnames
  $('#hostnames').on 'click', '.hostnameRemover', deleteHostname
  $('#hostnames').on 'click', '.hostnameRemover span', deleteHostname
  $('#addHostname').click () ->
    append()
