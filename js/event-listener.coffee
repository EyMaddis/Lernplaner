chrome.tabs.create {
  'url': "calendar.html"
}

chrome.tabs.onCreated.addListener( () ->
  alert "Page geladen!"
#  chrome.tabs.create {
#    'url': "calendar.html"
#  }

)