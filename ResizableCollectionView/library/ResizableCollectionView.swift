//
//  ResizableCollectionView.swift
//  ResizableCollectionView
//
//  Created by IOKA Masakazu on 2016/01/27.
//  Copyright © 2016年 nscallop. All rights reserved.
//

import UIKit

private struct DefaultNumberOfCells {
    static let min = 1
    static let max = 5
}
private let defaultMarginOfCells = CGFloat(2)
private let defaultThresholdOfZoom = CGFloat(0.5)

// MARK: - ResizableCollectionViewDelegate
public protocol ResizableCollectionViewDelegate : UICollectionViewDelegate {
    
    func willPinchIn(collectionView: ResizableCollectionView)
    func willPinchOut(collectionView: ResizableCollectionView)
    
    func didPinchIn(collectionView: ResizableCollectionView)
    func didPinchOut(collectionView: ResizableCollectionView)
    
}

// MARK: - ResizableCollectionViewDelegate - default implementation
extension ResizableCollectionViewDelegate {
    
    func willPinchIn(collectionView: ResizableCollectionView) {
        // nothing
    }
    func willPinchOut(collectionView: ResizableCollectionView) {
        // nothing
    }
    
    func didPinchIn(collectionView: ResizableCollectionView) {
        // nothing
    }
    func didPinchOut(collectionView: ResizableCollectionView) {
        // nothing
    }
    
}

// MARK: - ResizableCollectionViewDataSource
public protocol ResizableCollectionViewDataSource : UICollectionViewDataSource {
    
    func minNumberOfCellsInLine(collectionView: ResizableCollectionView) -> Int
    func maxNumberOfCellsInLine(collectionView: ResizableCollectionView) -> Int
    
    func marginOfCells(collectionView: ResizableCollectionView) -> CGFloat
    
    func thresholdOfZoom(collectionView: ResizableCollectionView) -> CGFloat
}

// MARK: - ResizableCollectionViewDataSource - default implementation
extension ResizableCollectionViewDataSource {
    func minNumberOfCellsInLine(collectionView: ResizableCollectionView) -> Int {
        return DefaultNumberOfCells.min
    }
    
    func maxNumberOfCellsInLine(collectionView: ResizableCollectionView) -> Int {
        return DefaultNumberOfCells.max
    }
    
    func marginOfCells(collectionView: ResizableCollectionView) -> CGFloat {
        return defaultMarginOfCells
    }
    
    func thresholdOfZoom(collectionView: ResizableCollectionView) -> CGFloat {
        return defaultThresholdOfZoom
    }
    
}

// MARK: - ResizableCollectionView
public class ResizableCollectionView: UICollectionView {
    
    /// ResizableCollectionViewDelegate
    override weak public var delegate: UICollectionViewDelegate? {
        didSet {
            assert(delegate == nil || delegate is ResizableCollectionViewDelegate, "The delegate must be of type 'ResizableCollectionDelegate'")
            self.myDelegate = delegate as? ResizableCollectionViewDelegate
        }
    }
    private weak var myDelegate: ResizableCollectionViewDelegate?
    
    /// ResizableCollectionViewDataSource
    override weak public var dataSource: UICollectionViewDataSource? {
        didSet {
            assert(delegate == nil || delegate is ResizableCollectionViewDataSource, "The dataSource must be of type 'ResizableCollectionViewDataSource'")
            self.myDataSource = dataSource as? ResizableCollectionViewDataSource
        }
    }
    private weak var myDataSource: ResizableCollectionViewDataSource?
    
    
    private var pinchGesture: UIPinchGestureRecognizer! = nil
    
    private var numberOfCells = 1
    private var zoomingStatus: ZoomStatus = .noZoom
    
    enum ZoomStatus {
        case noZoom
        case zoomIn
        case zoomOut
    }
    
    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self._init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._init()
    }
    
    private func _init() {
        self.collectionViewLayout = self.collectionViewFlowLayout(self.numberOfCells)
        self.enableGesture()
    }
    
    func pinch(gesture: UIPinchGestureRecognizer) {
        switch (gesture.state) {
        case .Began:
            let min = (self.myDataSource == nil) ? DefaultNumberOfCells.min : self.myDataSource!.minNumberOfCellsInLine(self)
            let max = (self.myDataSource == nil) ? DefaultNumberOfCells.max : self.myDataSource!.maxNumberOfCellsInLine(self)
            
            if gesture.scale > 1.0 && self.numberOfCells > min {
                self.zoomingStatus = .zoomIn
            } else if self.numberOfCells < max {
                self.zoomingStatus = .zoomOut
            }
            if self.zoomingStatus == .noZoom {
                return
            }
            
            let nextCount = self.nextNumberOfCells()
            let nextLayout = self.collectionViewFlowLayout(nextCount)
            self.startInteractiveTransitionToCollectionViewLayout(nextLayout, completion: {Void in
                self.enableGesture()
                self.zoomingStatus = .noZoom
            })
            break
        case .Changed:
            if self.zoomingStatus == .noZoom {
                return
            }
            (self.collectionViewLayout as? UICollectionViewTransitionLayout)?.transitionProgress = self.zoomProgressScale(gesture.scale)
            break
        case .Ended:
            if self.zoomingStatus == .noZoom {
                return
            }
            
            let threshold = (self.myDataSource == nil) ? defaultThresholdOfZoom : self.myDataSource!.thresholdOfZoom(self)
            if (self.collectionViewLayout as? UICollectionViewTransitionLayout)?.transitionProgress > threshold {
                self.finishInteractiveTransition()
                self.numberOfCells = self.nextNumberOfCells()
            } else {
                self.cancelInteractiveTransition()
            }
            self.disableGesture()
            
            self.reloadData()
            break
        default:
            // nothing
            break
        }
    }
    
    private func collectionViewFlowLayout(numberOfCells: Int) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let margin = (self.myDataSource == nil) ? defaultMarginOfCells : self.myDataSource!.marginOfCells(self)
        let cellWidth = (UIScreen.mainScreen().bounds.size.width - margin * (CGFloat(numberOfCells) + 1)) / CGFloat(numberOfCells)
        layout.itemSize = CGSize(width: cellWidth , height: cellWidth)
        layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin)
        layout.minimumInteritemSpacing = margin
        layout.minimumLineSpacing = margin
        return layout
    }
    
    private func nextNumberOfCells() -> Int {
        switch (self.zoomingStatus) {
        case .zoomIn:
            return self.numberOfCells - 1
        case .zoomOut:
            return self.numberOfCells + 1
        default:
            return self.numberOfCells
        }
    }
    
    private func zoomProgressScale(zoomScale: CGFloat) -> CGFloat {
        var scale: CGFloat = 0.0
        switch (self.zoomingStatus) {
        case .zoomIn:
            scale = zoomScale - 1.0
        case .zoomOut:
            scale = 2.0 - 2.0 * zoomScale
        default:
            scale = 0.0
        }
        scale = (scale > 1.0) ? 1.0 : scale
        scale = (scale < 0.0) ? 0.0 : scale
        return scale
    }
    
    private func enableGesture() {
        if self.pinchGesture == nil {
            self.pinchGesture = UIPinchGestureRecognizer()
            self.pinchGesture.addTarget(self, action: Selector("pinch:"))
        }
        self.addGestureRecognizer(self.pinchGesture)
    }
    
    private func disableGesture() {
        self.removeGestureRecognizer(self.pinchGesture)
    }
    
}
