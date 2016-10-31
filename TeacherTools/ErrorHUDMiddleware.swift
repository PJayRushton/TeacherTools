//
//  ErrorHUDMiddleware.swift
//  AmandasRecipes
//
//  Created by Parker Rushton on 5/10/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Whisper

struct DisplayNetworkLossMessage: Event { }

struct DisplayLoadingMessage: Event {
    var message: String?
}

struct DisplayMessage: Event {
    var message: String
}

struct DisplayUploadMessage: Event { }

struct ErrorEvent: Event {
    var error: Error?
    var message: String?
}

struct DisplayHugeErrorMessage: Event {
    var message: String
}

struct DisplaySuccessMessage: Event {
    var message: String
}

struct HideAlerts: Event { }


struct ErrorHUDMiddleware: Middleware {
    
    func process(event: Event, state: AppState) {
        switch event {
        case let event as ErrorEvent:
            print("ERROR:\(event.error) WITH MESSAGE: \(event.message)")
            
            guard let message = event.message else { break }
            silva(title: message, barColor: state.theme.tintColor)
        case let event as DisplayLoadingMessage:
            silva(title: event.message ?? "loading...", displayTime: 0)
        case let action as DisplayMessage:
            silva(title: action.message)
        case let action as DisplaySuccessMessage:
            silva(title: action.message, barColor: state.theme.mainColor)
        case _ as DisplayNetworkLossMessage:
            silva(title: "Looking for the internet...", barColor: UIColor.red.withAlphaComponent(0.6), displayTime: 0)
        case _ as DisplayUploadMessage:
            silva(title: "Uploading...", barColor: UIColor.lightGray.withAlphaComponent(0.75), displayTime: 0)
        case _ as HideAlerts:
            hide()
        default:
            break
        }

    }
    
    private func silva(title: String = "loading...", barColor: UIColor = UIColor.blue.withAlphaComponent(0.75), displayTime: TimeInterval? = nil) {
        let murmur = Murmur(title: title, backgroundColor: barColor, titleColor: .white, font: App.core.state.theme.fontType.font(withSize: 14))
        let time = displayTime == nil ? title.displayTime : displayTime!
        let action = time == 0 ? WhistleAction.present : WhistleAction.show(time)
        show(whistle: murmur, action: action)
    }
    
}


extension String {
    
    var displayTime: TimeInterval {
        var timeToDisplay = 1.0
        let characterCount = self.characters.count
        timeToDisplay += Double(characterCount) * 0.06 as TimeInterval
        
        return timeToDisplay
    }
    
}
