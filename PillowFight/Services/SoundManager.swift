import AVFoundation
import AudioToolbox

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    private init() {}
    
    func playHitSound() {
        // Generate a synthetic hit sound using AudioToolbox
        AudioServicesPlaySystemSound(1104)  // Subtle tap sound
    }
    
    func playSpecialSound() {
        AudioServicesPlaySystemSound(1109)  // More dramatic sound
    }
    
    func playKOSound() {
        AudioServicesPlaySystemSound(1304)  // Alert-style sound
    }
    
    func playRoundStart() {
        AudioServicesPlaySystemSound(1113)  // Bell-like sound
    }
    
    func playVictory() {
        AudioServicesPlaySystemSound(1115)  // Celebration sound
    }
    
    func playButtonTap() {
        AudioServicesPlaySystemSound(1306)  // UI tap
    }
}
