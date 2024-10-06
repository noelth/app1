// Project Setup for DynaKeys and DynaMusic (macOS version)

import SwiftUI
import AppKit
import AVFoundation
import IOKit
import IOKit.graphics



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
    @State private var brightnessLevel: Float = getScreenBrightness()
    
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
            .onChange(of: volumeLevel) { oldValue, newValue in setSystemVolume(level: newValue) }
            
            // Brightness Control Slider
            Text("Brightness Control")
                .font(.headline)
            Slider(value: Binding(
                get: { self.brightnessLevel },
                set: { newValue in
                    self.brightnessLevel = newValue
                    setScreenBrightness(level: newValue) // Update screen brightness when slider changes
                }
            ), in: 0...1)
            .padding()
            .onChange(of: brightnessLevel) { oldValue, newValue in setScreenBrightness(level: newValue) }
        }
        .padding()
    }
}

// macOS specific functions to control volume and brightness
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

func getScreenBrightness() -> Float {
    let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IODisplayConnect"))
    guard service != 0 else {
        print("Error getting display service")
        return 0.5
    }
    var brightness: Float = 0.5
    let result = IODisplayGetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, &brightness)
    IOObjectRelease(service)
    guard result == kIOReturnSuccess else {
        print("Error getting screen brightness")
        return 0.5
    }
    return brightness
}

func setScreenBrightness(level: Float) {
    let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IODisplayConnect"))
    guard service != 0 else {
        print("Error getting display service")
        return
    }
    let result = IODisplaySetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, level)
    IOObjectRelease(service)
    guard result == kIOReturnSuccess else {
        print("Error setting screen brightness")
        return
    }
    print("Setting brightness level to: \(level)") // Debug output to confirm brightness change
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
        // Handle playback logic using AVFoundation or MediaPlayer
        print(isPlaying ? "Playing music" : "Pausing music") // Debug output to confirm playback state
    }
    
    func updateNowPlayingInfo() {
        // Update now playing information from system or streaming API
        nowPlaying = "Current Track - Artist Name" // Placeholder for current track info
        print("Updated now playing info: \(nowPlaying)") // Debug output to confirm now playing info
    }
}
