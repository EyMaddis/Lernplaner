class TabInfo
  costructor: (@id,@time) ->

class ScoreManager
  HOUR_BONUS = 20
  BONUS = 1
  MALUS = 1

  constructor : () ->
    @score = 0

  newPhase: (hours) ->
    hours = hours || 1
    @score = hours * HOUR_BONUS

  giveBonus: (time) ->
    time = time || 1
    @score += time * BONUS

  giveMalus: (time) ->
    time = time || 1
    @score -= time * MALUS

badtab = []

currentTabs = []

scoreManager = new ScoreManager()

updateCurrentTabs = (callback)->
  currentTabs = []
  chrome.tabs.query({}, (tabs) ->
    for tab in tabs
      currentTabs.push tab.id
    console.log currentTabs
    callback()
  )


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
  blocked = ['kaleydra.de','facebook.com','www.facebook.com']


  if changeInfo.status == 'complete'
    url = new URL(tab.url)

    updateCurrentTabs () ->


      if url.hostname in blocked
        opt = {
          type: "basic",
          title: "Wolltest du nicht lernen?",
          message: 'Nicht ablenken lassen!',
          iconUrl: "images/calendar-icon_128.png"
        }
        unless tab.id in badtab
          console.log badtab
          badtab.push tab.id
          console.log badtab
        chrome.notifications.create 'superId'+Math.random(), opt, () ->
          console.log 'notification callback!'
   )

chrome.tabs.onRemoved.addListener((tab, removeInfo) ->

  badtabtemp = []
  updateCurrentTabs () ->
    console.log badtab
    unless badtab.length == 0
      for bad in badtab
        for current in currentTabs
          console.log bad
          console.log current
          if bad == current
            badtabtemp.push (bad)
    console.log badtabtemp
    badtab = badtabtemp
    badtabtemp = []
    console.log badtab
)

