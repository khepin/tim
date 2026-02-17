import AVFoundation

class BrownNoiseGenerator {
    static let volume: Float = 1

    private var engine: AVAudioEngine?
    private var lastSample: Float = 0.0
    private var isPlaying = false

    func start() {
        guard !isPlaying else { return }

        let engine = AVAudioEngine()
        let sampleRate = engine.outputNode.outputFormat(forBus: 0).sampleRate
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let vol = BrownNoiseGenerator.volume

        let sourceNode = AVAudioSourceNode(format: format) { [unowned self] _, _, frameCount, bufferList in
            let buffer = UnsafeMutableAudioBufferListPointer(bufferList)
            let frames = Int(frameCount)

            for channel in buffer {
                let data = channel.mData!.assumingMemoryBound(to: Float.self)
                for frame in 0..<frames {
                    let white = Float.random(in: -1...1)
                    self.lastSample += white * 0.005
                    self.lastSample = max(-1, min(1, self.lastSample))
                    data[frame] = self.lastSample * vol
                }
            }
            return noErr
        }

        engine.attach(sourceNode)
        engine.connect(sourceNode, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
            self.engine = engine
            isPlaying = true
            NSLog("[BrownNoise] engine started, isRunning=%d", engine.isRunning)
        } catch {
            NSLog("[BrownNoise] engine failed: %@", error.localizedDescription)
        }
    }

    func stop() {
        guard isPlaying else { return }
        engine?.stop()
        engine = nil
        lastSample = 0
        isPlaying = false
    }
}
