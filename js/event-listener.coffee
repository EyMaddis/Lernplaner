chrome.webNavigation.onCompleted.addListener( () ->
  alert "Page geladen!"
  chrome.tabs.create {
    'url': "calendar.html"
  }

)