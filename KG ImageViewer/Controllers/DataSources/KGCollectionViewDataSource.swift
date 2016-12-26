//
//  KGCollectionViewDataSource.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 08-12-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import UIKit

protocol CollectionViewDataSource {
    associatedtype dataType
    var data: [dataType] { get set }
    var cellIdentifier: String { get set }
}

class KGCollectionViewDataSource<DataType>: NSObject, CollectionViewDataSource, UICollectionViewDataSource {
    
    typealias dataType = DataType
    var data: [dataType] = []
    var cellIdentifier = "CellIdentifier"
    
    init(cellIdentifier: String) {
        super.init()
        self.cellIdentifier = cellIdentifier
    }
    
    func reset() {
        data = []
    }
    
    func insertData(_ newData: [dataType], inCollectionView collectionView: UICollectionView) {
        guard data.count > 0 else {
            data = newData
            collectionView.reloadData()
            return
        }
        DispatchQueue.global(qos: .default).async {
            [unowned self] in
            let lastItem = self.data.count
            self.data += newData
            
            let indexPaths = (lastItem..<self.data.count).map { IndexPath(item: $0, section: 0) }
            DispatchQueue.main.async {
                [unowned self] in
                if self.data.count < indexPaths.count {
                    assert(false, "Something went wrong with the calculation for index paths")
                    return
                }
                collectionView.insertItems(at: indexPaths)
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        return cell
    }
    
}
