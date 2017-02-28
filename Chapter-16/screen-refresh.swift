import Cocoa

class AppController: NSObject, NSApplicationDelegate {
    var mainWindow: NSWindow?
    let rect = NSMakeRect(200, 400, 820, 500)

    func applicationDidFinishLaunching(aNotification: NSNotification) {
		print(rect)	
        let window = NSWindow(contentRect: rect,
                              styleMask: NSTitledWindowMask | NSClosableWindowMask,
                              backing: NSBackingStoreType.Buffered,
                              defer: false)
        window.orderFrontRegardless()
        self.mainWindow = window
        NSApp.activateIgnoringOtherApps(true)
        redrawALot()
    }
  func redrawALot() {
	for _ in 1...600 {
	  let window=self.mainWindow!
	  window.contentView!.lockFocus()
	  NSColor.whiteColor().set()
	  NSBezierPath.fillRect(rect)
	  NSColor.blackColor().set()
	  "Iteration".drawAtPoint( NSPoint(x:10, y:10), withAttributes: nil)
	  window.contentView!.unlockFocus()
	  window.flushWindow()
	  sleep(1)
	  NSLog("flush")
	}
	NSApp.terminate( true )
  }

    func applicationShouldTerminateAfterLastWindowClosed(app: NSApplication) -> Bool {
        return true
    }
}

NSApplication.sharedApplication()
NSApp.setActivationPolicy(.Regular)

let controller = AppController()
NSApp.delegate = controller

NSApp.run()
