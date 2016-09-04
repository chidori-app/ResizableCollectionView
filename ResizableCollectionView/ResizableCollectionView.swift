//
//  ResizableCollectionView.swift
//  ResizableCollectionView
//
//  Created by IOKA Masakazu on 2016/01/27.
//  Copyright © 2016年 nscallop. All rights reserved.
//

import UIKit

fileprivate struct DefaultNumberOfCells {
    static let min = 1
    static let max = 5
}
fileprivate let defaultMarginBetweenCells = CGFloat(2)
fileprivate let defaultOutlineMargin = CGFloat(2)
fileprivate let defaultThresholdOfZoom = CGFloat(0.5)

// MARK: - ResizableCollectionViewDelegate
public protocol ResizableCollectionViewDelegate : UICollectionViewDelegate {
    
    func willPinchIn(_ collectionView: ResizableCollectionView)
    func willPinchOut(_ collectionView: ResizableCollectionView)
    
    func didPinchIn(_ collectionView: ResizableCollectionView)
    func didPinchOut(_ collectionView: ResizableCollectionView)
    
}

// MARK: - ResizableCollectionViewDelegate - default implementation
public extension ResizableCollectionViewDelegate {
    
    func willPinchIn(_ collectionView: ResizableCollectionView) {
        // nothing
    }
    func willPinchOut(_ collectionView: ResizableCollectionView) {
        // nothing
    }
    
    func didPinchIn(_ collectionView: ResizableCollectionView) {
        // nothing
    }
    func didPinchOut(_ collectionView: ResizableCollectionView) {
        // nothing
    }
    
}

// MARK: - ResizableCollectionViewDataSource
public protocol ResizableCollectionViewDataSource : UICollectionViewDataSource {
    
    func minNumberOfCellsInLine(_ collectionView: ResizableCollectionView) -> Int
    func maxNumberOfCellsInLine(_ collectionView: ResizableCollectionView) -> Int
    
    func marginBetweenCells(_ collectionView: ResizableCollectionView) -> CGFloat
    func outlineMargin(_ collectionView: ResizableCollectionView) -> CGFloat
    
    func thresholdOfZoom(_ collectionView: ResizableCollectionView) -> CGFloat
}

// MARK: - ResizableCollectionViewDataSource - default implementation
public extension ResizableCollectionViewDataSource {
    func minNumberOfCellsInLine(_ collectionView: ResizableCollectionView) -> Int {
        return DefaultNumberOfCells.min
    }
    
    func maxNumberOfCellsInLine(_ collectionView: ResizableCollectionView) -> Int {
        return DefaultNumberOfCells.max
    }
    
    func marginBetweenCells(_ collectionView: ResizableCollectionView) -> CGFloat {
        return defaultMarginBetweenCells
    }
    
    func outlineMargin(_ collectionView: ResizableCollectionView) -> CGFloat {
        return defaultOutlineMargin
    }
    
    func thresholdOfZoom(_ collectionView: ResizableCollectionView) -> CGFloat {
        return defaultThresholdOfZoom
    }
    
}

// MARK: - ResizableCollectionView
open class ResizableCollectionView: UICollectionView {
    
    fileprivate var _numberOfCells = DefaultNumberOfCells.min
    open var numberOfCells: Int {
        get {
            return self._numberOfCells
        }
        set {
            let min = (self.myDataSource == nil) ? DefaultNumberOfCells.min : self.myDataSource!.minNumberOfCellsInLine(self)
            let max = (self.myDataSource == nil) ? DefaultNumberOfCells.max : self.myDataSource!.maxNumberOfCellsInLine(self)
            let value = (newValue < min) ? min : newValue
            self._numberOfCells = (value > max) ? max : value
            self.collectionViewLayout = self.collectionViewFlowLayout(self._numberOfCells)
            self.reloadData()
        }
    }
    
    /// ResizableCollectionViewDelegate
    override weak open var delegate: UICollectionViewDelegate? {
        didSet {
            assert(delegate == nil || delegate is ResizableCollectionViewDelegate, "The delegate must be of type 'ResizableCollectionViewDelegate'")
            self.myDelegate = delegate as? ResizableCollectionViewDelegate
        }
    }
    fileprivate weak var myDelegate: ResizableCollectionViewDelegate?
    
    /// ResizableCollectionViewDataSource
    override weak open var dataSource: UICollectionViewDataSource? {
        didSet {
            assert(delegate == nil || delegate is ResizableCollectionViewDataSource, "The dataSource must be of type 'ResizableCollectionViewDataSource'")
            self.myDataSource = dataSource as? ResizableCollectionViewDataSource
            
            // update display
            self._numberOfCells = self.myDataSource!.minNumberOfCellsInLine(self)
            self.collectionViewLayout = self.collectionViewFlowLayout(self._numberOfCells)
        }
    }
    fileprivate weak var myDataSource: ResizableCollectionViewDataSource?
    
    
    fileprivate var pinchGesture: UIPinchGestureRecognizer! = nil
    
    fileprivate var zoomingStatus: ZoomStatus = .noZoom
    
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
    
    fileprivate func _init() {
        self.collectionViewLayout = self.collectionViewFlowLayout(self._numberOfCells)
        self.enableGesture()
    }
    
    func pinch(_ gesture: UIPinchGestureRecognizer) {
        switch (gesture.state) {
        case .began:
            let min = (self.myDataSource == nil) ? DefaultNumberOfCells.min : self.myDataSource!.minNumberOfCellsInLine(self)
            let max = (self.myDataSource == nil) ? DefaultNumberOfCells.max : self.myDataSource!.maxNumberOfCellsInLine(self)
            
            if gesture.scale > 1.0 && self._numberOfCells > min {
                self.zoomingStatus = .zoomIn
                self.myDelegate?.willPinchOut(self)
            } else if self._numberOfCells < max {
                self.zoomingStatus = .zoomOut
                self.myDelegate?.willPinchIn(self)
            }
            if self.zoomingStatus == .noZoom {
                return
            }
            
            let nextCount = self.nextNumberOfCells()
            let nextLayout = self.collectionViewFlowLayout(nextCount)
            self.startInteractiveTransition(to: nextLayout, completion: {Void in
                self.enableGesture()
                
                switch (self.zoomingStatus) {
                case .zoomIn:
                    self.myDelegate?.didPinchOut(self)
                    break
                case .zoomOut:
                    self.myDelegate?.didPinchIn(self)
                    break
                default:
                    // nothing
                    break
                }
                
                self.zoomingStatus = .noZoom
            })
            break
        case .changed:
            if self.zoomingStatus == .noZoom {
                return
            }
            (self.collectionViewLayout as? UICollectionViewTransitionLayout)?.transitionProgress = self.zoomProgressScale(gesture.scale)
            break
        case .ended:
            if self.zoomingStatus == .noZoom {
                return
            }
            
            let threshold = (self.myDataSource == nil) ? defaultThresholdOfZoom : self.myDataSource!.thresholdOfZoom(self)
            if ((self.collectionViewLayout as? UICollectionViewTransitionLayout)?.transitionProgress)! > threshold {
                self.finishInteractiveTransition()
                self._numberOfCells = self.nextNumberOfCells()
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
    
    fileprivate func collectionViewFlowLayout(_ numberOfCells: Int) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let marginCells: CGFloat
        let marginOutline: CGFloat
        if self.myDataSource == nil {
            marginCells = defaultMarginBetweenCells
            marginOutline = defaultOutlineMargin
        } else {
            marginCells = self.myDataSource!.marginBetweenCells(self)
            marginOutline = self.myDataSource!.outlineMargin(self)
        }
        let sumOfCellWidths = UIScreen.main.bounds.size.width - (2.0 * marginOutline + CGFloat(numberOfCells-1) * marginCells)
        let cellWidth = sumOfCellWidths / CGFloat(numberOfCells)
        layout.itemSize = CGSize(width: cellWidth , height: cellWidth)
        layout.sectionInset = UIEdgeInsetsMake(marginOutline, marginOutline, marginOutline, marginOutline)
        layout.minimumInteritemSpacing = marginCells
        layout.minimumLineSpacing = marginCells
        return layout
    }
    
    fileprivate func nextNumberOfCells() -> Int {
        switch (self.zoomingStatus) {
        case .zoomIn:
            return self._numberOfCells - 1
        case .zoomOut:
            return self._numberOfCells + 1
        default:
            return self._numberOfCells
        }
    }
    
    fileprivate func zoomProgressScale(_ zoomScale: CGFloat) -> CGFloat {
        var scale: CGFloat = 0.0
        switch (self.zoomingStatus) {
        case .zoomIn:
            scale = zoomScale / 2.0 - 0.25
        case .zoomOut:
            scale = 2.0 - 2.0 * zoomScale
        default:
            scale = 0.0
        }
        scale = (scale > 1.0) ? 1.0 : scale
        scale = (scale < 0.0) ? 0.0 : scale
        return scale
    }
    
    fileprivate func enableGesture() {
        if self.pinchGesture == nil {
            self.pinchGesture = UIPinchGestureRecognizer()
            self.pinchGesture.addTarget(self, action: #selector(ResizableCollectionView.pinch(_:)))
        }
        self.addGestureRecognizer(self.pinchGesture)
    }
    
    fileprivate func disableGesture() {
        self.removeGestureRecognizer(self.pinchGesture)
    }
    
}
