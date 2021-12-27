//
//  SnapshotState.swift
//  TestMarvelAPI
//
//  Created by Mario Julià on 30/12/21.
//

import Foundation
import UIKit

struct SnapshotState<T: Hashable, U: Hashable, V: Error> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<T, U>
    
    let snapshot : Snapshot
    let contentOffset : CGPoint
    let lastError : V?
}
