//
//  KGImageCollectionViewDataSource.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 08-12-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import UIKit

class KGImageCollectionViewDataSource: KGCollectionViewDataSource<ImageData> {
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        if let cell = cell as? KGImageCell {
            let imageData = data[indexPath.item]
            let imageURL = imageData.url
            cell.imageURL = imageURL!
        }
        return cell
    }
}
