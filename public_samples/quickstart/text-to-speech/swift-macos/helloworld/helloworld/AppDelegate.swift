//
// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE.md file in the project root for full license information.
//

// <code>
import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTextFieldDelegate, AVAudioPlayerDelegate {
    var textField: NSTextField!
    var synthesisButton: NSButton!
    
    var inputText: String!
    
    var sub: String!
    var region: String!
    
    var player: AVAudioPlayer?

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("loading")
        // load subscription information
        sub = "YourSubscriptionKey"
        region = "YourServiceRegion"
        
        inputText = ""
        
        textField = NSTextField(frame: NSRect(x: 100, y: 200, width: 200, height: 50))
        textField.textColor = NSColor.black
        textField.lineBreakMode = .byWordWrapping
        
        textField.placeholderString = "Type something to synthesize."
        textField.delegate = self
        
        self.window.contentView?.addSubview(textField)
        
        synthesisButton = NSButton(frame: NSRect(x: 100, y: 100, width: 200, height: 30))
        synthesisButton.title = "Synthesize"
        synthesisButton.target = self
        synthesisButton.action = #selector(synthesisButtonClicked)
        self.window.contentView?.addSubview(synthesisButton)
    }
    
    @objc func synthesisButtonClicked() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.synthesize()
        }
    }
    
    func synthesize() {
        var speechConfig: SPXSpeechConfiguration?
        do {
            try speechConfig = SPXSpeechConfiguration(subscription: sub, region: region)
        } catch {
            print("error \(error) happened")
            speechConfig = nil
        }
        speechConfig?.setSpeechSynthesisOutputFormat( SPXSpeechSynthesisOutputFormat.audio16Khz32KBitRateMonoMp3)
        let synthesizer = try! SPXSpeechSynthesizer(speechConfiguration: speechConfig!, audioConfiguration: nil)
        let result = try! synthesizer.speakText(inputText)
        if result.reason == SPXResultReason.canceled
        {
            let cancellationDetails = try! SPXSpeechSynthesisCancellationDetails(fromCanceledSynthesisResult: result)
            print("cancelled, error code: \(cancellationDetails.errorCode) detail: \(String(describing: cancellationDetails.errorDetails)) ")
            return
        }
        do {
            try player = AVAudioPlayer(data: result.audioData!)
            player?.delegate = self
            player?.prepareToPlay()
        } catch {
            print("error \(error) happened")
            player = nil
        }
        player?.play()
    }
    
    func controlTextDidChange(_ obj: Notification) {
        let textFiled = obj.object as! NSTextField
        inputText = textFiled.stringValue
    }
    
}
// </code>
