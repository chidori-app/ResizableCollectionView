//
//  ResizableCollectionView.swift
//  ResizableCollectionView
//
//  Created by IOKA Masakazu on 2016/01/27.
//  Copyright © 2016年 nscallop. All rights reserved.
//

import UIKit

public protocol ResizableCollectionViewDelegate : UICollectionViewDelegate {
    
    func willPinchIn(collectionView: ResizableCollectionView)
    func willPinchOut(collectionView: ResizableCollectionView)

    func didPinchIn(collectionView: ResizableCollectionView)
    func didPinchOut(collectionView: ResizableCollectionView)
    
}

public protocol ResizableCollectionViewDataSource : UICollectionViewDataSource {
    
    func minNumberOfCellsInLine(collectionView: ResizableCollectionView) -> Int

    func maxNumberOfCellsInLine(collectionView: ResizableCollectionView) -> Int

}

public class ResizableCollectionView: UICollectionView {
    
    /// ResizableCollectionViewDelegate
    override weak public var delegate: UICollectionViewDelegate? {
        didSet {
            assert(delegate == nil || delegate is ResizableCollectionViewDelegate, "The delegate must be of type 'ResizableCollectionDelegate'")
        }
    }
    
    /// ResizableCollectionViewDataSource
    override weak public var dataSource: UICollectionViewDataSource? {
        didSet {
            assert(delegate == nil || delegate is ResizableCollectionViewDataSource, "The dataSource must be of type 'ResizableCollectionViewDataSource'")
        }
    }
    
    private var pinchGesture: UIPinchGestureRecognizer! = nil
    
    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
