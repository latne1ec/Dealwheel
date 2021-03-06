//
//  AudioManager.swift
//  Dealwheel
//
//  Created by Evan Latner on 6/13/17.
//  Copyright © 2017 dealwheel. All rights reserved.
//

import Foundation
import AVFoundation

open class AudioManager {
    
    fileprivate static let _instance = AudioManager()
    static var Instance: AudioManager {
        return _instance
    }
    
    var mainScreenPlayer: AVAudioPlayer?
    var tickNoisePlayer: AVAudioPlayer?
    var soundEffectPlayer: AVAudioPlayer?
    var prizeWheelPlayer: AVAudioPlayer?
    var prizeWheelMusic = Bundle.main.url(forResource: "kayneShort", withExtension: "m4a")
    var mainMusicUrl = Bundle.main.url(forResource: "mainTrimmed", withExtension: "m4a")
    var tickNoise = Bundle.main.url(forResource: "tick", withExtension: "mp3")
    var spinNoise = Bundle.main.url(forResource: "spin", withExtension: "wav")
    var m1and7 = Bundle.main.url(forResource: "1and7", withExtension: "wav")
    var m2and8 = Bundle.main.url(forResource: "2and8", withExtension: "wav")
    var m3and9 = Bundle.main.url(forResource: "3and9", withExtension: "wav")
    var m4and10 = Bundle.main.url(forResource: "4and10", withExtension: "wav")
    var m6and11 = Bundle.main.url(forResource: "6and11", withExtension: "wav")
    var m7and12 = Bundle.main.url(forResource: "7and12", withExtension: "wav")
    
    open func initTickNoisePlayer () {
        do {
            self.tickNoisePlayer = try AVAudioPlayer(contentsOf: spinNoise!)
            self.tickNoisePlayer?.prepareToPlay()
            
        } catch { print("error") }
    }
    
    open func playSpinSound () {
        if self.tickNoisePlayer != nil {
            self.tickNoisePlayer?.play()
        }
    }
    
    open func stopSpinSound () {
        if self.tickNoisePlayer != nil {
            if (self.tickNoisePlayer?.isPlaying)! {
                self.tickNoisePlayer?.pause()
            }
        }
    }
    
    open func playMainScreenMusic () {
        
        pausePrizewheelMusic()
        
        if self.mainScreenPlayer != nil {
            if (self.mainScreenPlayer?.isPlaying)! {
                return
            }
        }
        
        do {
            self.mainScreenPlayer = try AVAudioPlayer(contentsOf: mainMusicUrl!)
            self.mainScreenPlayer?.prepareToPlay()
            self.mainScreenPlayer?.numberOfLoops = -1
            self.mainScreenPlayer?.play()
            
        } catch {
            print("error")
        }
    }
    
    open func pauseMainScreenMusic () {
        if self.mainScreenPlayer != nil {
            if (self.mainScreenPlayer?.isPlaying)! {
                self.mainScreenPlayer?.pause()
            }
        }
    }
    
    open func playPrizeWheelMusic () {
        
        if self.prizeWheelPlayer != nil {
            if (self.prizeWheelPlayer?.isPlaying)! {
                return
            }
        }
        
        do {
            self.prizeWheelPlayer = try AVAudioPlayer(contentsOf: prizeWheelMusic!)
            self.prizeWheelPlayer?.prepareToPlay()
            self.prizeWheelPlayer?.numberOfLoops = -1
            self.prizeWheelPlayer?.play()
            
        } catch {
            print("error")
        }
    }
    
    open func pausePrizewheelMusic () {
        if self.prizeWheelPlayer != nil {
            if (self.prizeWheelPlayer?.isPlaying)! {
                self.prizeWheelPlayer?.pause()
            }
        }
    }
    
    open func playSoundForWedgeAtIndex(_ index: Int) {
        
        pauseMainScreenMusic()
        pausePrizewheelMusic()
        switch index {
        case 0:
            do {
                self.soundEffectPlayer = try AVAudioPlayer(contentsOf: m1and7!)
                self.soundEffectPlayer?.prepareToPlay()
                self.soundEffectPlayer?.play()
                
            } catch { print("error") }
        case 1:
            do {
                self.soundEffectPlayer = try AVAudioPlayer(contentsOf: m2and8!)
                self.soundEffectPlayer?.prepareToPlay()
                self.soundEffectPlayer?.play()
                
            } catch { print("error") }
        case 2:
            do {
                self.soundEffectPlayer = try AVAudioPlayer(contentsOf: m3and9!)
                self.soundEffectPlayer?.prepareToPlay()
                self.soundEffectPlayer?.play()
                
            } catch { print("error") }
        case 3:
            do {
                self.soundEffectPlayer = try AVAudioPlayer(contentsOf: m4and10!)
                self.soundEffectPlayer?.prepareToPlay()
                self.soundEffectPlayer?.play()
                
            } catch { print("error") }
        case 4:
            do {
                self.soundEffectPlayer = try AVAudioPlayer(contentsOf: m4and10!)
                self.soundEffectPlayer?.prepareToPlay()
                self.soundEffectPlayer?.play()
                
            } catch { print("error") }
        case 5:
            do {
                self.soundEffectPlayer = try AVAudioPlayer(contentsOf: m6and11!)
                self.soundEffectPlayer?.prepareToPlay()
                self.soundEffectPlayer?.play()
                
            } catch { print("error") }
        case 6:
            do {
                self.soundEffectPlayer = try AVAudioPlayer(contentsOf: m7and12!)
                self.soundEffectPlayer?.prepareToPlay()
                self.soundEffectPlayer?.play()
                
            } catch { print("error") }
        case 7:
            do {
                self.soundEffectPlayer = try AVAudioPlayer(contentsOf: m2and8!)
                self.soundEffectPlayer?.prepareToPlay()
                self.soundEffectPlayer?.play()
                
            } catch { print("error") }
        case 8:
            do {
                self.soundEffectPlayer = try AVAudioPlayer(contentsOf: m3and9!)
                self.soundEffectPlayer?.prepareToPlay()
                self.soundEffectPlayer?.play()
                
            } catch { print("error") }
        case 9:
            do {
                self.soundEffectPlayer = try AVAudioPlayer(contentsOf: m4and10!)
                self.soundEffectPlayer?.prepareToPlay()
                self.soundEffectPlayer?.play()
                
            } catch { print("error") }
        case 10:
            do {
                self.soundEffectPlayer = try AVAudioPlayer(contentsOf: m6and11!)
                self.soundEffectPlayer?.prepareToPlay()
                self.soundEffectPlayer?.play()
                
            } catch { print("error") }
        case 11:
            do {
                self.soundEffectPlayer = try AVAudioPlayer(contentsOf: m7and12!)
                self.soundEffectPlayer?.prepareToPlay()
                self.soundEffectPlayer?.play()
                
            } catch { print("error") }
        default:
            print("default")
        }
    }
}
