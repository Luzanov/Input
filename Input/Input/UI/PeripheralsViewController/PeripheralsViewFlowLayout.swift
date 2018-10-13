//
//  PeripheralsViewFlowLayout.swift
//  Input
//
//  Created by LuzanovRoman on 30.03.2018.
//  Copyright © 2018 LuzanovRoman. All rights reserved.
//

import UIKit

class PeripheralsViewFlowLayout: UICollectionViewFlowLayout {

    fileprivate var insertingIndexPaths = [IndexPath]()
    fileprivate var deletingIndexPaths = [IndexPath]()
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else { return nil }
        let cellX = self.sectionInset.left + CGFloat(attributes.indexPath.row) * (self.itemSize.width + self.minimumLineSpacing)
        attributes.frame = CGRect(x: cellX, y: self.sectionInset.top, width: self.itemSize.width, height: self.itemSize.height)
        return attributes
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let layoutAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        guard layoutAttributes.count > 0 else { return layoutAttributes }
        
        var modifidedLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for layoutAttribute in layoutAttributes {
            guard let modifidedLayoutAttribute = self.layoutAttributesForItem(at: layoutAttribute.indexPath) else { continue }
            modifidedLayoutAttributes.append(modifidedLayoutAttribute)
        }
        return modifidedLayoutAttributes
    }

    override var collectionViewContentSize: CGSize {
        get {
            guard let collectionView = self.collectionView else { return CGSize.zero }
            guard let dataSource = collectionView.dataSource else { return CGSize.zero }

            let itemCount = CGFloat(dataSource.collectionView(collectionView, numberOfItemsInSection: 0))
            var width = (itemCount * self.itemSize.width) + max(itemCount - 1, 0) * self.minimumLineSpacing
            width += self.sectionInset.left + self.sectionInset.right
            return CGSize(width: width, height: self.itemSize.height)
        }
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        
        self.insertingIndexPaths.removeAll()
        self.deletingIndexPaths.removeAll()
        
        for updateItem in updateItems {
            if let indexPath = updateItem.indexPathAfterUpdate, updateItem.updateAction == .insert {
                self.insertingIndexPaths.append(indexPath)
            }
            if let indexPath = updateItem.indexPathBeforeUpdate, updateItem.updateAction == .delete {
                self.deletingIndexPaths.append(indexPath)
            }
        }
    }
    
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        self.insertingIndexPaths.removeAll()
        self.deletingIndexPaths.removeAll()
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) else { return nil }
        
        if self.insertingIndexPaths.contains(itemIndexPath) {
            attributes.alpha = 0.0
            attributes.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }
        return attributes
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) else { return nil }
        
        if self.deletingIndexPaths.contains(itemIndexPath) {
            attributes.alpha = 0.0
            attributes.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }
        return attributes
    }
}
