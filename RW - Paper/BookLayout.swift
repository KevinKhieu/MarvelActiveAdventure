//
//  BookLayout.swift
//  RW - Paper
//
//  Created by Joachim  on 10/2/17.
//  Copyright © 2017 -. All rights reserved.
//

import UIKit

class BookLayout: UICollectionViewFlowLayout {

    private let PageWidth: CGFloat = 362
    private let PageHeight: CGFloat = 568
    private var numberOfItems = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepare() {
        super.prepare()
        let bgImage = UIImageView();
        bgImage.image = UIImage(named: "marvelbg");
        bgImage.contentMode = .scaleToFill
        
        collectionView?.backgroundView = bgImage
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
        numberOfItems = collectionView!.numberOfItems(inSection: 0)
        collectionView?.isPagingEnabled = true
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: (CGFloat(numberOfItems / 2)) * collectionView!.bounds.width, height: collectionView!.bounds.height)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        //1
        var array: [UICollectionViewLayoutAttributes] = []
        
        //2
        for i in 0 ... max(0, numberOfItems - 1) {
            //3
            let indexPath = IndexPath(row: i, section: 0)
            //4
            let attributes = layoutAttributesForItem(at: indexPath)
            if attributes != nil {
                //5
                array.append(attributes!)
            }
        }
        //6
        return array
    }
    
    //MARK: - Attribute Logic Helpers
    
    func getFrame(collectionView: UICollectionView) -> CGRect {
        var frame = CGRect()
        
        frame.origin.x = (collectionView.bounds.width / 2) - (PageWidth / 2) + collectionView.contentOffset.x
        frame.origin.y = (collectionViewContentSize.height - PageHeight) / 2
        frame.size.width = PageWidth
        frame.size.height = PageHeight
        
        return frame
    }
    
    func getRatio(collectionView: UICollectionView, indexPath: NSIndexPath) -> CGFloat {
        //1
        let page = CGFloat(indexPath.item - indexPath.item % 2) * 0.5
        
        //2
        var ratio: CGFloat = -0.5 + page - (collectionView.contentOffset.x / collectionView.bounds.width)
        
        //3
        if ratio > 0.5 {
            ratio = 0.5 + 0.1 * (ratio - 0.5)
            
        } else if ratio < -0.5 {
            ratio = -0.5 + 0.1 * (ratio + 0.5)
        }
        
        return ratio
    }
    
    func getAngle(indexPath: NSIndexPath, ratio: CGFloat) -> CGFloat {
        // Set rotation
        var angle: CGFloat = 0
        
        //1
        if indexPath.item % 2 == 0 {
            // The book's spine is on the left of the page
            angle = (1-ratio) * CGFloat(-(CGFloat.pi/2))
        } else {
            //2
            // The book's spine is on the right of the page
            angle = (1 + ratio) * CGFloat(CGFloat.pi/2)
        }
        //3
        // Make sure the odd and even page don't have the exact same angle
        angle += CGFloat(indexPath.row % 2) / 1000
        //4
        return angle
    }
    
    func makePerspectiveTransform() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -2000
        return transform
    }
    
    func getRotation(indexPath: NSIndexPath, ratio: CGFloat) -> CATransform3D {
        var transform = makePerspectiveTransform()
        let angle = getAngle(indexPath: indexPath, ratio: ratio)
        transform = CATransform3DRotate(transform, angle, 0, 1, 0)
        return transform
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?{
        //1
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        //2
        let frame = getFrame(collectionView: collectionView!)
        layoutAttributes.frame = frame
        
        //3
        let ratio = getRatio(collectionView: collectionView!, indexPath: indexPath as NSIndexPath)
        
        //4
        if ratio > 0 && indexPath.item % 2 == 1
            || ratio < 0 && indexPath.item % 2 == 0 {
            // Make sure the cover is always visible
            if indexPath.row != 0 {
                return nil
            }
        }
        //5
        let rotation = getRotation(indexPath: indexPath as NSIndexPath, ratio: min(max(ratio, -1), 1))
        layoutAttributes.transform3D = rotation
        
        //6
        if indexPath.row == 0 {
            layoutAttributes.zIndex = Int.max
        }
        
        return layoutAttributes
    }
}
