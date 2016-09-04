//
//  ViewController.swift
//  DEMO
//
//  Created by hitting on 2016/02/09.
//  Copyright © 2016年 IOKA Masakazu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    fileprivate static let colors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.white]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//MARK: - ResizableCollectionViewDelegate
extension ViewController: ResizableCollectionViewDelegate {
    
    func willPinchIn(collectionView: ResizableCollectionView) {
        print("will pinch in")
    }
    
    func willPinchOut(collectionView: ResizableCollectionView) {
        print("will pinch out")
    }
    
    func didPinchIn(collectionView: ResizableCollectionView) {
        print("did pinch in")
    }
    
    func didPinchOut(collectionView: ResizableCollectionView) {
        print("did pinch out")
    }
    
}

//MARK: - ResizableCollectionViewDataSource
extension ViewController: ResizableCollectionViewDataSource {
    func minNumberOfCellsInLine(_ collectionView: ResizableCollectionView) -> Int {
        return 2
    }
    

    func maxNumberOfCellsInLine(_ collectionView: ResizableCollectionView) -> Int {
        return 6
    }
    
    func marginBetweenCells(_ collectionView: ResizableCollectionView) -> CGFloat {
        return CGFloat(10)
    }
    
    func outlineMargin(_ collectionView: ResizableCollectionView) -> CGFloat {
        return CGFloat(5)
    }
    
    func thresholdOfZoom(_ collectionView: ResizableCollectionView) -> CGFloat {
        return CGFloat(0.6)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath)
        cell.backgroundColor = ViewController.colors[indexPath.row % ViewController.colors.count]
        return cell
    }
    
}
