//
//  ViewController.swift
//  Project-Group6
//
//  Created by Cena Nguyen on 2026-07-02.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {
    
    var player: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let url = Bundle.main.url(forResource: "song1",
                                     withExtension: "mp3") {

            player = try? AVAudioPlayer(contentsOf: url)
            player?.play()

        }

    }


}

