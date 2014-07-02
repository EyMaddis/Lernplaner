badtab = []

scoreManager = new ScoreManager()

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

    if url.hostname in blocked
      opt = {
        type: "basic",
        title: "Wolltest du nicht lernen?",
        message: 'Nicht ablenken lassen!',
        iconUrl: "images/calendar-icon_128.png"
      }
      badtab.push tab.id
      chrome.notifications.create 'superId'+Math.random(), opt, () ->
        console.log 'notification callback!'
 )

chrome.tabs.onRemoved.addListener((tab, changeInfo) ->
 if tab.id in badtab
   badtab.splice(tab.id)
)


class ScoreManager
  HOUR_BONUS = 20
  BONUS = 1
  MALUS = 1

  constructor : () ->
    @score = 0

  newPhase: (hours) ->
    @score = hours * HOUR_BONUS

  giveBonus: (time) ->
    time = time || 1
    @score += time * BONUS

  giveMalus: (time) ->
    time = time || 1
    @score -= time * MALUS








