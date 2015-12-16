# CoachKit

[![CI Status](http://img.shields.io/travis/NativeMobile/CoachKit.svg?style=flat)](https://travis-ci.org/NativeMobile/CoachKit)
[![Version](https://img.shields.io/cocoapods/v/CoachKit.svg?style=flat)](http://cocoapods.org/pods/CoachKit)
[![License](https://img.shields.io/cocoapods/l/CoachKit.svg?style=flat)](http://cocoapods.org/pods/CoachKit)
[![Platform](https://img.shields.io/cocoapods/p/CoachKit.svg?style=flat)](http://cocoapods.org/pods/CoachKit)

A Swift framework that allows a coach or trainer to connect their device to 7 class member devices via multipeer connectivity in order to conduct a training session.

## Benefits

* Peer objects are reused - When a peer is created, it is persisted to NSUserDefaults as recommended by Apple in the [WWDC 2014 talk](https://developer.apple.com/videos/play/wwdc2014-709/). If you don't do this, you can end up with multiple connections to the same peer.

* Backgrounding - multipeer connections cannot be maintained in the background. CoachKit handles releasing connections when the app is backgrounded and automatically re-establishing them when the app returns to the foreground.

* Consistent thread handling - All calls made from the framework to the delagtes are made on the UI thread. This means you only need to think about threading if you do any heavy lifting when handling a callback, in which case you are responsible for jumping onto a background thread.

* Comprehensive logging - By implementing the single function of the ActivityLogger protocol you can direct logging produced by the framework in whatever way you want. The example app shows how the logging can be displayed in a UITableView and this can be very helpful during development.  

* Supports both iOS and OSX

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

From the coach side, create a CoachingManager and register a delegate

    var manager: CoachingManager?
    manager = CoachingManager(serviceName: "coachkit-demo", peerConnectionManagerDelegate: self)
    manager!.startCoachingSession()


The delegate protocol provides a range of functions that notify the coach when students join or leave the class and when messages are recieved from them.

The framework provides a default implementation that extends any class that implements ActivityLogger.

    public protocol ActivityLogger {
        func addLogItem(message: String)
    }

By implementing ActivityLogger you can log all connnection activity and peer messaging and you are then free to implement any of the functions of the delegate that are of interest to you. As a minimum, you will want to implement the function that is called when a message is received from one of the class members:

        func didReceiveDictionaryFromPeerWithName(name: String, dictionary: Dictionary<String, AnyObject>)

The coach can send a message to all connected class members by calling

    func sendMessageToPeers(dictionary: Dictionary<String, AnyObject>, success: ()->(), failure: (error: String)-> ())

The student connects in a similar way to the coach

    var manager: CoachConnectionManager?
    manager = CoachConnectionManager(serviceName: "coachkit-demo", peerConnectionListenerDelegate: self)
    manager!.connectToCoach()

It is possible for the same class to implement both the peerConnectionManagerDelegate and the peerConnectionListenerDelegate

## Note

At this stage the framework uses the device name to create the Peer object for that device. This means that all devices you wish to connect together must have unique device names.

## Requirements

iOS8.0 OSX10.10
## Installation

CoachKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "CoachKit"
```

## Author

Keith Coughtrey, keith@nativemobile.co.nz

## License

CoachKit is available under the MIT license. See the LICENSE file for more info.
