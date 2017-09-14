//
//  UserProfileOrganizationDatasource.swift
//  GHClient
//
//  Created by Pi on 05/03/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import UIKit

internal final class RepoHitsDatasource: ValueCellDataSource {

  internal func set(items: [RepoProfile]) {
    self.set(values: items,
             cellClass: RepoCollectionViewCell.self,
             inSection: 0)
  }

  override func configureCell(collectionCell cell: UICollectionViewCell,
                              withValue value: Any,
                              for indexPath: IndexPath) {
    switch (cell, value) {
    case let (cell as RepoCollectionViewCell, item as RepoProfile):
      cell.configureWith(value: item)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
