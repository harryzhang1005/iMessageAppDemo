//
//  MessagesViewController.swift
//  iMsgAppDemo MessagesExtension
//
//  Created by Hongfei Zhang on 10/1/17.
//  Copyright © 2017 Deja View Concepts, Inc. All rights reserved.
//

import UIKit
import Messages

// This is the root vc for your iMessage app's UI. MainInterface.storyboard where you can design your iMessage app's interface.
class MessagesViewController: MSMessagesAppViewController {
	
	@IBOutlet weak var stepper: UIStepper!
	
	@IBOutlet weak var valueLabel: UILabel! {
		didSet {
			valueLabel.layer.cornerRadius = valueLabel.frame.size.width/2.0
		}
	}
	
	var stickers = [MSSticker]()	// Only for Test-1: Custom Stickers App
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		
		// Test-1: Custom Stickers App
//		loadStickers()
//		createStickerBrowser()
		
		// Test-2: Custom iMessage App
		self.valueLabel.text = "0"
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		if let label = valueLabel {
			label.layer.cornerRadius = label.frame.size.width/2.0
		}
	}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: - Helpers
	
	/*
	In this case, we only loaded local sticker images into our custom application for simplicity. One of the main advantages to using a custom sticker application, however, is that you can load sticker images from a remote server and even, through the use of other view controllers before showing your MSStickerBrowserViewController, let your users create their own stickers. 
	*/
	func loadStickers() {
		for i in 1...2 {
			if let url = Bundle.main.url(forResource: "Sticker \(i)", withExtension: "png") {
				do {
					let sticker = try MSSticker(contentsOfFileURL: url, localizedDescription: "Try Sticker")
					self.stickers.append(sticker)
				} catch {
					print("HZ: \(error.localizedDescription)")
				}
			}
		}
	}
	
	func createStickerBrowser() {
		let controller = MSStickerBrowserViewController(stickerSize: MSStickerSize.large)
		addChildViewController(controller)
		view.addSubview(controller.view)
		
		controller.stickerBrowserView.backgroundColor = UIColor.blue
		controller.stickerBrowserView.dataSource = self
		
		view.topAnchor.constraint(equalTo: controller.view.topAnchor).isActive = true
		view.leftAnchor.constraint(equalTo: controller.view.leftAnchor).isActive = true
		view.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor).isActive = true
		view.rightAnchor.constraint(equalTo: controller.view.rightAnchor).isActive = true
	}
	
	// We take the current value of the stepper and put it in a circular label. We then render this label into a UIImage object which we can attach to our message.
	func createImageForMessage() -> UIImage? {
		
		let bgView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
		bgView.backgroundColor = UIColor.white
		
		let label = UILabel(frame: CGRect(x: 75, y: 75, width: 150, height: 150))
		label.font = UIFont.systemFont(ofSize: 56.0)
		label.backgroundColor = UIColor.red
		label.textColor = UIColor.white
		label.text = "\(Int(stepper.value))"
		label.textAlignment = .center
		label.layer.cornerRadius = label.frame.size.width/2.0
		label.clipsToBounds = true
		
		bgView.addSubview(label)
		bgView.frame.origin = CGPoint(x: view.frame.size.width, y: view.frame.size.height)
		view.addSubview(bgView)
		
		UIGraphicsBeginImageContextWithOptions(bgView.frame.size, false, UIScreen.main.scale)
		bgView.drawHierarchy(in: bgView.bounds, afterScreenUpdates: true)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		bgView.removeFromSuperview()
		
		return image
	}
	
	func createImageForMessage2() -> UIImage? {
		
		UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.main.scale)
		view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image
	}
	
	// MARK: - Actions
	
	/*
	# MSConversation
	It represents the currently open converation. You can use this class in order to manipulate the conversation transcript, for example by inserting messages or getting the currently selected message.
	
	# MSMessage
	It represents a single message, whether created by you to insert into the conversation or already existing in the conversation
	
	# MSMessageTemplateLayout
	It create a message bubble for you to display your custom message in. It is important to note that the space in the top left of this layout will be filled by your iMessage app's icon.
	
	*/
	
	// Test-2: Custom iMessage App
	@IBAction func createMessage(_ sender: UIButton) {
		// this gives you access to the active conversation. You can't access the content of messages other than those created by your extension.
		if let image = createImageForMessage(), let conversation = activeConversation {
			let layout = MSMessageTemplateLayout()
			layout.image = image
			layout.caption = "Stepper Value"
			
			let msg = MSMessage()
			msg.layout = layout
			msg.url = URL(string: "emptyURL")	// This url is intended to link to a web page of some sort where macOS users can also view your custom iMessage content.
			
			// Insert the message into the current active conversation. Calling this method does not actually send the message, though -- instead it puts your message in the user's entry field so that they can press send themselves.
			conversation.insert(msg, completionHandler: { (error) in
				print(error ?? "OK")
			})
		}
	}
	
	@IBAction func valueDidChanged(_ sender: UIStepper) {
		self.valueLabel.text = "\(Int(sender.value))"
	}
	
    // MARK: - Conversation Handling / Messages extension 's lifecycle
	
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
    }
	
	override func didBecomeActive(with conversation: MSConversation) {
		// x
	}
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
	
	// There is another set of functions to track when a user taps on the message bubble, e.g. didSelect, didReceive.
	// The information that tracking message functions are not called if the extension is inactive and the user taps on the message bubble.
	
	override func didSelect(_ message: MSMessage, conversation: MSConversation) {
		// x
	}
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
	
	/* The presentation style defines how the extension appears in the Messages app.
	let currentPresentationStyle = presentationStyle		// get presentation style
	self.requestPresentationStyle(currentPresentationStyle)	// set presentation style
	willTransition(to: currentPresentationStyle)	// at the beginning of style transition
	didTransition(to: currentPresentationStyle)		// at the end of style transition
	*/
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }

}

// MARK: - MSStickerBrowserViewDataSource methods

// In this case, we are just going to create our UI programmatically using the MSStickerBrowserViewController class.
extension MessagesViewController: MSStickerBrowserViewDataSource {
	
	func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
		return stickers.count
	}
	
	func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
		return stickers[index]
	}
	
}
