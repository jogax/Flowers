//
//  FMSynthetiser.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 01/06/2016.
//  Copyright © 2016 Jozsef Romhanyi. All rights reserved.
//

import AVFoundation
import Foundation



// The single FM synthesizer instance.
private let gFMSynthesizer: FMSynthesizer = FMSynthesizer()

public class FMSynthesizer {
    
    // The maximum number of audio buffers in flight. Setting to two allows one
    // buffer to be played while the next is being written.
    private let kInFlightAudioBuffers: Int = 2
    
    // The number of audio samples per buffer. A lower value reduces latency for
    // changes but requires more processing but increases the risk of being unable
    // to fill the buffers in time. A setting of 1024 represents about 23ms of
    // samples.
    private let kSamplesPerBuffer: AVAudioFrameCount = 1024
    
    // The audio engine manages the sound system.
    private let audioEngine: AVAudioEngine = AVAudioEngine()
    
    // The player node schedules the playback of the audio buffers.
    private let playerNode: AVAudioPlayerNode = AVAudioPlayerNode()
    
    // Use standard non-interleaved PCM audio.
    private let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)
    
    // A circular queue of audio buffers.
    private var audioBuffers: [AVAudioPCMBuffer] = [AVAudioPCMBuffer]()
    
    // The index of the next buffer to fill.
    private var bufferIndex: Int = 0
    
    // The dispatch queue to render audio samples.
    private let audioQueue: dispatch_queue_t = dispatch_queue_create("FMSynthesizerQueue", DISPATCH_QUEUE_SERIAL)
    
    // A semaphore to gate the number of buffers processed.
    private let audioSemaphore: dispatch_semaphore_t
    
    public class func sharedSynth() -> FMSynthesizer {
        return gFMSynthesizer
    }
    
    private init() {
        // init the semaphore
        audioSemaphore = dispatch_semaphore_create(kInFlightAudioBuffers)
        
        // Create a pool of audio buffers.
        audioBuffers = [AVAudioPCMBuffer](count: 2, repeatedValue: AVAudioPCMBuffer(PCMFormat: audioFormat, frameCapacity: UInt32(kSamplesPerBuffer)))
        
        // Attach and connect the player node.
        audioEngine.attachNode(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: audioFormat)
        
        do {
            try audioEngine.start()
        } catch {
            print("AudioEngine didn't start")
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FMSynthesizer.audioEngineConfigurationChange(_:)), name: AVAudioEngineConfigurationChangeNotification, object: audioEngine)
    }
    
    public func play(carrierFrequency: Float32, modulatorFrequency: Float32, modulatorAmplitude: Float32) {
        let unitVelocity = Float32(2.0 * M_PI / audioFormat.sampleRate)
        let carrierVelocity = carrierFrequency * unitVelocity
        let modulatorVelocity = modulatorFrequency * unitVelocity
        dispatch_async(audioQueue) {
            var sampleTime: Float32 = 0
            while true {
                // Wait for a buffer to become available.
                dispatch_semaphore_wait(self.audioSemaphore, DISPATCH_TIME_FOREVER)
                
                // Fill the buffer with new samples.
                let audioBuffer = self.audioBuffers[self.bufferIndex]
                let leftChannel = audioBuffer.floatChannelData[0]
                let rightChannel = audioBuffer.floatChannelData[1]
                for sampleIndex in 0 ..< Int(self.kSamplesPerBuffer) {
                    let sample = sin(carrierVelocity * sampleTime + modulatorAmplitude * sin(modulatorVelocity * sampleTime))
                    leftChannel[sampleIndex] = sample
                    rightChannel[sampleIndex] = sample
                    sampleTime = sampleTime + 1.0
                }
                audioBuffer.frameLength = self.kSamplesPerBuffer
                
                // Schedule the buffer for playback and release it for reuse after
                // playback has finished.
                self.playerNode.scheduleBuffer(audioBuffer) {
                    dispatch_semaphore_signal(self.audioSemaphore)
                    return
                }
                
                if sampleTime > 1000 {return}
                
                self.bufferIndex = (self.bufferIndex + 1) % self.audioBuffers.count
            }
        }
        
        playerNode.pan = 0.8
        playerNode.play()
    }
    
    @objc private func audioEngineConfigurationChange(notification: NSNotification) -> Void {
        NSLog("Audio engine configuration change: \(notification)")
    }
    
}

// Play a bell sound:
// FMSynthesizer.sharedSynth().play(440.0, modulatorFrequency: 679.0, modulatorAmplitude: 0.8)