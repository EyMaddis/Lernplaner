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
  ScoreManager.HOUR_BONUS = 20
  ScoreManager.BONUS = 1
  ScoreManager.MALUS = 1

  constructor : () ->
    @score = 0

  newPhase: (hours) ->
    hours = hours || 1
    @score = hours * ScoreManager.HOUR_BONUS

  giveBonus: (time) ->
    time = time || 1
    @score += time * ScoreManager.BONUS

  giveMalus: (time) ->
    time = time || 1
    @score -= time * ScoreManager.MALUS

forceTwoDigits = (val) ->
  if val < 10
    return "0#{val}"
  return val

formatDate = (date) ->
  hour = forceTwoDigits(date.getHours())
  minute = forceTwoDigits(date.getMinutes())
  return "#{hour}#{minute}"

isInLearningPhase = false
badtab = []
blocked = [] #[/facebook.com$/,/9gag.com$/,/reddit.com$/,/ebay.de$/,/amazon.de$/,/twitter.com$/,/tumblr.com$/,/fb.com$/]

distractionStart = null
distractionTime = 0
learnTimeStart = 0
learnTime = 0

MIL_TO_MIN = 60000


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

  console.log 'updated tab, learning?', isInLearningPhase
  if isInLearningPhase and changeInfo.status == 'complete'
    url = new URL(tab.url)
    console.log 'bevor update'
    updateCurrentTabs () ->
      console.log 'in update'
      badtabtemp = []
      if tab.id in badtab
        for bad in badtab
          unless bad == tab.id
            badtabtemp.push bad
            console.log 'bad tab!'
        badtab = badtabtemp
      console.log 'nach tab id check', badtab, blocked
      for block in blocked
        console.log 'block check', block
        regEx = new RegExp "#{block}$"
        if url.hostname.match regEx
          console.log 'matched!'
          opt = {
            type: "basic",
            title: "Wolltest du nicht lernen?",
            message: 'Nicht ablenken lassen!',
            iconUrl: "images/calendar-icon_128.png"
          }
          unless tab.id in badtab
            badtab.push tab.id
            if distractionStart == null
              distractionStart = Date.now()
              console.log distractionStart

          console.log 'notification!'
          chrome.notifications.create 'superId'+Math.random(), opt, () ->
            console.log 'notification callback!'
            console.log 'badtab = ', badtab
   )

chrome.tabs.onRemoved.addListener((tab, removeInfo) ->
  badtabtemp = []
  console.log 'removed tab, learning?', isInLearningPhase
  if not isInLearningPhase
    return
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
    if badtab.length == 0
      unless distractionStart == null
        distractionEnd = Date.now()
        distractionTime = distractionTime + ((distractionEnd - distractionStart)*MIL_TO_MIN)
        console.log 'distraction time = ', distractionTime
      distractionStart = null
    console.log 'badtab =' , badtab
)

chrome.runtime.onMessage.addListener (request) ->
  type = request.type

  goodTime = (learnTimeStart - Date.now()) / MIL_TO_MIN || 0
  badTime = distractionTime || 0
  score = (goodTime * ScoreManager.BONUS) - (badTime * ScoreManager.MALUS)

  if type is 'hostnames'
    blocked = request.hostnames
    console.log 'hostnames erhalten', blocked
  else if type is 'openPopup'
    chrome.runtime.sendMessage {
      isInLearningPhase: isInLearningPhase
      score: score
      type: 'openPopupResponse'
    }
  else if type is 'startLearning'
    isInLearningPhase = true
    learnTimeStart = Date.now()
    alert 'Lernphase gestartet!'
  else if type is 'stopLearning'
    isInLearningPhase = false
    badtab = []
    learnTimeEnd = Date.now()
    learnTime = learnTimeEnd - learnTimeStart
    learnTime /= MIL_TO_MIN
    scoreManager.giveBonus(learnTime)
    scoreManager.giveMalus(distractionTime)
    alert "Lernphase beendet! Gesammelte Punkte: #{scoreManager.score}" # , gelernte Zeit #{learnTime}, abgelenkt: #{distractionTime}
  else
    console.log 'invalid message received', request
