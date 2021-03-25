//
//  ViewController.swift
//  MonkeyPinch
//
//  Created by Жанадил on 3/24/21.
//  Copyright © 2021 Жанадил. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    let chompPlayer = AVAudioPlayer(fileName: "chomp")
    let laughPlayer = AVAudioPlayer(fileName: "hehehe")
    
    
    //настроили так чтобы при нажатии на обьект возпроизводился звук
  @IBOutlet var interactiveSubviews: [UIImageView]! {
      didSet {
        for subview in interactiveSubviews {
          let tapRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(handleTap)
          )
          tapRecognizer.delegate = self
          subview.addGestureRecognizer(tapRecognizer)
        }
      }
    }
    
    //Чтобы передвигать обьект с помощья пальца
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let recognizerView = sender.view else{
            return
        }
        
        let translation = sender.translation(in: view)
        recognizerView.center.x += translation.x
        recognizerView.center.y += translation.y
        sender.setTranslation(.zero, in: view)
        laughPlayer.play()
        
        //Deceleration effect (то есть когда останавливаем передвижение, в зависимости от скорости передвижения физика забрасывает наш обьект)
        guard sender.state == .ended else{
            return
        }
        
        let velocity = sender.velocity(in: view)
        let vectorToFinalPoint = CGPoint(x: velocity.x / 15, y: velocity.y / 15)
        let bounds = view.bounds.inset(by: view.safeAreaInsets)
        var finalPoint = recognizerView.center
        finalPoint.x += vectorToFinalPoint.x
        finalPoint.y += vectorToFinalPoint.y
        finalPoint.x = min(max(finalPoint.x, bounds.minX), bounds.maxX)
        finalPoint.y = min(max(finalPoint.y, bounds.minY), bounds.maxY)
        let vectorToFinalPointLength = (
            vectorToFinalPoint.x * vectorToFinalPoint.x
                + vectorToFinalPoint.y * vectorToFinalPoint.y
            ).squareRoot()
        
        UIView.animate(
            withDuration: TimeInterval(vectorToFinalPointLength / 1800),
            delay: 0,
            options: .curveEaseOut,
            animations: { recognizerView.center = finalPoint }
        )
    }
    
    
    //Увеличивает или уменьшает размеры нашего обьекта
    @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
        guard let recognizerView = sender.view else {
          return
        }
        
        recognizerView.transform = recognizerView.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
    
    
    //Переворачивает наш обьект
    @IBAction func handleRotation(_ sender: UIRotationGestureRecognizer) {
        guard let recognizerView = sender.view else {
          return
        }
        recognizerView.transform = recognizerView.transform.rotated(by: sender.rotation)
        sender.rotation = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // настроили так чтобы звук воспроизводился только по нажатию на обьект (когда будем передвигать его
        // никакого звука не будет)
        interactiveSubviews.map {
             $0.gestureRecognizers!.first { $0 is UIPanGestureRecognizer }!
           }
           .forEach { panRecognizer in
             panRecognizer.view!.gestureRecognizers!
             .first { $0 is UITapGestureRecognizer }!
             .require(toFail: panRecognizer)
           }
    }
    
    @objc func handleTap(_: UITapGestureRecognizer) {
        chompPlayer.play()
    }
}


//Дает нам возможность выполнять все 3 операции одновременно
extension ViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
    return true
  }
}

//Обрабатываем звуковой файл
extension AVAudioPlayer {
  convenience init(fileName: String) {
    let url = Bundle.main.url(forResource: fileName, withExtension: "caf")!
    try! self.init(contentsOf: url)
    prepareToPlay()
  }
}
