pragma Singleton
import Quickshell

Singleton {
    id: root
    property var activePopup: null
    property var activeWrapper: null      // replaces activePopup
    property real expandHeight: 0         // bar listens to this
    
    function open(wrapper) {
        if (activeWrapper && activeWrapper !== wrapper) {
            activeWrapper.forceClose()    // close previous immediately
        }
        activeWrapper = wrapper
        expandHeight = wrapper.totalPopupHeight
    }
    
    function close() {
        activeWrapper = null
        expandHeight = 0
    }
}
