// Project Setup for DynaKeys and DynaMusic (macOS version)

import SwiftUI
import AppKit
import AVFoundation

struct ContentView: View {
    var body: some View {
        TabView {
            DynaKeysView()
                .tabItem {
                    Label("DynaKeys", systemImage: "keyboard")
                }
            DynaMusicView()
                .tabItem {
                    Label("DynaMusic", systemImage: "music.note")
                }
        }
    }
}

// DynaKeys Feature
struct DynaKeysView: View {
    @State private var volumeLevel: Float = getSystemVolume()
    
    var body: some View {
        VStack {
            // Volume Control Slider
            Text("Volume Control")
                .font(.headline)
            Slider(value: Binding(
                get: { self.volumeLevel },
                set: { newValue in
                    self.volumeLevel = newValue
                    setSystemVolume(level: newValue) // Update system volume when slider changes
                }
            ), in: 0...1)
            .padding()
            .onAppear {
                // Listen for volume change notifications using NotificationCenter
                NotificationCenter.default.addObserver(forName: NSNotification.Name("VolumeDidChange"), object: nil, queue: .main) { _ in
                    self.volumeLevel = getSystemVolume()
                }
                
                // Set up property listener for real-time volume changes
                let audioObjectID = AudioObjectID(kAudioObjectSystemObject)
                var propertyAddress = AudioObjectPropertyAddress(
                    mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
                    mScope: kAudioDevicePropertyScopeOutput,
                    mElement: kAudioObjectPropertyElementMain
                )
                AudioObjectAddPropertyListener(audioObjectID, &propertyAddress, volumeDidChangeCallback, nil)
            }
        }
        .padding()
    }
}
                set: { newValue in
                    self.volumeLevel = newValue
                    setSystemVolume(level: newValue) // Update system volume when slider changes
                }
            ), in: 0...1)
            .padding()
            .onAppear {
                // Listen for volume change notifications
                let audioObjectID = AudioObjectID(kAudioObjectSystemObject)
                var propertyAddress = AudioObjectPropertyAddress(
                    mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
                    mScope: kAudioDevicePropertyScopeOutput,
                    mElement: kAudioObjectPropertyElementMain
                )
                AudioObjectAddPropertyListener(audioObjectID, &propertyAddress, volumeDidChangeCallback, nil)
            }
        }
        .padding()
    }
}

// Callback function for volume changes
func volumeDidChangeCallback(objectID: AudioObjectID, numberAddresses: UInt32, addresses: UnsafePointer<AudioObjectPropertyAddress>, clientData: UnsafeMutableRawPointer?) -> OSStatus {
    DispatchQueue.main.async {
        NotificationCenter.default.post(name: NSNotification.Name("VolumeDidChange"), object: nil)
    }
    return noErr
}

// macOS specific functions to control volume
func getSystemVolume() -> Float {
    var defaultOutputDeviceID = AudioDeviceID(0)
    var propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultOutputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    
    var dataSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
    let status = AudioObjectGetPropertyData(
        AudioObjectID(kAudioObjectSystemObject),
        &propertyAddress,
        0,
        nil,
        &dataSize,
        &defaultOutputDeviceID
    )
    guard status == noErr else {
        print("Error getting default output device ID")
        return 0.5
    }
    
    var volume: Float = 0.5
    propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
        mScope: kAudioDevicePropertyScopeOutput,
        mElement: kAudioObjectPropertyElementMain
    )
    dataSize = UInt32(MemoryLayout.size(ofValue: volume))
    let volumeStatus = AudioObjectGetPropertyData(
        defaultOutputDeviceID,
        &propertyAddress,
        0,
        nil,
        &dataSize,
        &volume
    )
    guard volumeStatus == noErr else {
        print("Error getting system volume")
        return 0.5
    }
    return volume
}

func setSystemVolume(level: Float) {
    var defaultOutputDeviceID = AudioDeviceID(0)
    var propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultOutputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    
    var dataSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
    let status = AudioObjectGetPropertyData(
        AudioObjectID(kAudioObjectSystemObject),
        &propertyAddress,
        0,
        nil,
        &dataSize,
        &defaultOutputDeviceID
    )
    guard status == noErr else {
        print("Error getting default output device ID")
        return
    }
    
    var volume = level
    propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
        mScope: kAudioDevicePropertyScopeOutput,
        mElement: kAudioObjectPropertyElementMain
    )
    dataSize = UInt32(MemoryLayout.size(ofValue: volume))
    let volumeStatus = AudioObjectSetPropertyData(
        defaultOutputDeviceID,
        &propertyAddress,
        0,
        nil,
        dataSize,
        &volume
    )
    guard volumeStatus == noErr else {
        print("Error setting system volume")
        return
    }
    print("Setting volume level to: \(level)") // Debug output to confirm volume change
}

// DynaMusic Feature
struct DynaMusicView: View {
    @State private var isPlaying = false
    @State private var nowPlaying: String = "No Track Playing" // Default now playing text
    
    var body: some View {
        VStack {
            // Now Playing Text
            Text(nowPlaying)
                .font(.headline)
                .padding()
            
            // Play/Pause Button
            Button(action: {
                // Toggle playback state with smooth animation when button is pressed
                withAnimation(.easeInOut(duration: 0.3)) {
                    isPlaying.toggle()
                    togglePlayback() // Start or pause playback
                }
            }) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.largeTitle)
                    .scaleEffect(isPlaying ? 1.2 : 1.0) // Scale animation for button interaction
            }
            .padding()
        }
        .padding()
        .onAppear {
            updateNowPlayingInfo() // Update now playing information when view appears
        }
    }
    
    func togglePlayback() {
        let script = "tell application \"System Events\" to key code 16 using {command down, option down}"
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", script]
        task.launch()
        print(isPlaying ? "Playing media" : "Pausing media") // Debug output to confirm playback state
    }
    
    func updateNowPlayingInfo() {
        nowPlaying = "Media Control Active" // Placeholder for current track info
        print("Updated now playing info: \(nowPlaying)") // Debug output to confirm now playing info
    }
}
