//
//  NavigationEvent.js
//  Waldo
//
//  Copyright © 2018 DFeichtinger. All rights reserved.
//

// Source: https://stackoverflow.com/questions/9012537/how-to-get-the-element-clicked-for-the-whole-document#9012576
document.addEventListener('click', function(e) {
    e = e || window.event;
    var target = e.target || e.srcElement,
        text = target.textContent || target.innerText;
        cleanedText = text.replace(/\s+/g, ' ').trim();
    window.webkit.messageHandlers.followLinkHandler.postMessage(cleanedText);
}, false);
