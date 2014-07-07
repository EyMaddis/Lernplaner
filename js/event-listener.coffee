###
TODO
endsWith = (hostname, blockedSuffix) ->
...hostname.indexOf(blockedSuffix, hostname.length - blockedSuffix.length) !== -1;
blockedSuffix immer der Form: ".facebook.com"
endsWith("www.facebook.com", ".facebook.com") -> true!
###

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

isInLearningPhase = false
badtab = []
blocked = ['kaleydra.de','facebook.com','www.facebook.com']

currentTabs = []

scoreManager = new ScoreManager()

updateCurrentTabs = (callback)->
  currentTabs = []
  chrome.tabs.query({}, (tabs) ->
    for tab in tabs
      currentTabs.push tab.id
    console.log currentTabs
    console.log 'badtab = ',badtab
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
        for bad in badtab
          if tab.id == bad.id
            console.log badtab
            badtab.push new TabInfo(tab.id, new Date)
            console.log badtab
        chrome.notifications.create 'superId'+Math.random(), opt, () ->
          console.log 'notification callback!'
          console.log 'badtab = ', badtab
   )

chrome.tabs.onRemoved.addListener((tab, removeInfo) ->

  badtabtemp = []
  updateCurrentTabs () ->
    #console.log badtab
    unless badtab.length == 0
      for bad in badtab
        for current in currentTabs
          #console.log bad
          #console.log current
          if bad == current
            badtabtemp.push (bad)
    #console.log badtabtemp
    badtab = badtabtemp
    badtabtemp = []
    console.log 'badtab =' , badtab
)

chrome.runtime.onMessage.addListener (request) ->
  type = request.type
  if type is 'hostnames'
    blocked = request.hostnames
    console.log 'hostnames erhalten', blocked
  else if type is 'startLearning'
    isInLearningPhase = true
    alert 'Lernphase gestartet!'
  else # stop learning
    isInLearningPhase = false
    alert 'Lernphase beendet!'