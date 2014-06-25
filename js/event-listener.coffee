callback = (event) ->
  console.log event
  opt = {
    type: "basic",
    title: "Seite geladen!",
    message: event.url,
    iconUrl: "images/calendar-icon_128.png"
  }
  chrome.notifications.create 'superId'+Math.random(), opt, () ->
    console.log 'notification callback!'


chrome.webNavigation.onCompleted.addListener callback, {
  url: [
    { hostSuffix: 'kaleydra.de'},
    { hostSuffix: 'facebook.com'}]
}
