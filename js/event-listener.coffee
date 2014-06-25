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


chrome.tabs.onUpdated.addListener ((event,changeInfo, tab) ->
  blocked = ['kaleydra.de','facebook.com']

  opt = {
    type: "basic",
    title: "Seite geladen!",
    message: event.url,
    iconUrl: "images/calendar-icon_128.png"
  }

  if changeInfo.status == 'complete'
    url = tab.url
    console.log(url)

    for badUrl in blocked
      regex = new RegExp(badUrl);

      if regex.test(url)
        chrome.notifications.create 'superId'+Math.random(), opt, () ->
          console.log 'notification callback!'
 )


