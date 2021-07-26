window.GoogleDrivePlayer = class GoogleDrivePlayer extends VideoJSPlayer
    constructor: (data) ->
        if not (this instanceof GoogleDrivePlayer)
            return new GoogleDrivePlayer(data)

        super(data)

    load: (data) ->
        if not window.hasDriveUserscript
            window.promptToInstallDriveUserscript()
        else if window.hasDriveUserscript
            window.maybePromptToUpgradeUserscript()
        if typeof window.getGoogleDriveMetadata is 'function'
            setTimeout(=>
                backoffRetry((cb) ->
                    window.getGoogleDriveMetadata(data.id, cb)
                , (error, metadata) =>
                    if error
                        console.error(error)
                        alertBox = window.document.createElement('div')
                        alertBox.className = 'alert alert-danger'
                        alertBox.textContent = error
                        document.getElementById('ytapiplayer').appendChild(alertBox)
                    else
                        data.meta.direct = metadata.videoMap
                        super(data)
                , {
                    maxTries: 3
                    delay: 1000
                    factor: 1.2
                    jitter: 500
                })
            , Math.random() * 1000)

window.promptToInstallDriveUserscript = ->
    if document.getElementById('prompt-install-drive-userscript')
        return
    alertBox = document.createElement('div')
    alertBox.id = 'prompt-install-drive-userscript'
    alertBox.className = 'alert alert-info'
    alertBox.innerHTML = """
Due to continual breaking changes making it increasingly difficult to
maintain Google Drive support, Google Drive now requires installing
a userscript in order to play the video."""
    alertBox.appendChild(document.createElement('br'))
    infoLink = document.createElement('a')
    infoLink.className = 'btn btn-info'
    infoLink.href = '/google_drive_userscript'
    infoLink.textContent = 'Click here for details'
    infoLink.target = '_blank'
    alertBox.appendChild(infoLink)

    closeButton = document.createElement('button')
    closeButton.className = 'close pull-right'
    closeButton.innerHTML = '&times;'
    closeButton.onclick = ->
        alertBox.parentNode.removeChild(alertBox)
    alertBox.insertBefore(closeButton, alertBox.firstChild)
    removeOld($('<div/>').append(alertBox))
