//
//  AudioHelper.swift
//  TeacherTools
//
//  Created by Parker Rushton on 12/21/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation
import AVFoundation

class AudioHelper {

    fileprivate var player: AVAudioPlayer
    
    enum AudioError: Error {
        case fileFailed
    }
    
    enum AudioResource: String {
        case drumroll
        
        var url: URL {
            return Bundle.main.url(forResource: rawValue, withExtension: "mp3")!
        }
    }
    
    init?(resource: AudioResource) {
        do {
            player = try AVAudioPlayer(contentsOf: resource.url)
        } catch {
            print(error)
            return nil
        }
    }
    
    func play() {
        player.prepareToPlay()
        player.play()
    }
    
}
