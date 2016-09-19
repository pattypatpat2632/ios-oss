import Library
import UIKit

internal final class DiscoveryFiltersDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case collectionsHeader
    case collections
    case favoritesHeader
    case favorites
    case categoriesHeader
    case categories
  }

  internal func load(topRows rows: [SelectableRow], categoryId: Int?) {
    self.set(values: [(title: Strings.Collections(), categoryId: categoryId)],
             cellClass: DiscoveryFiltersStaticRowCell.self,
             inSection: Section.collectionsHeader.rawValue)

    let rowsAndId = rows.map { (row: $0, categoryId: categoryId) }
    self.set(values: rowsAndId,
             cellClass: DiscoverySelectableRowCell.self,
             inSection: Section.collections.rawValue)
  }

  internal func load(favoriteRows rows: [SelectableRow], categoryId: Int?) {
    self.set(values: [(title: Strings.discovery_filters_favorites_title(), categoryId: categoryId)],
             cellClass: DiscoveryFiltersStaticRowCell.self,
             inSection: Section.favoritesHeader.rawValue)

    let rowsAndId = rows.map { (row: $0, categoryId: categoryId) }
    self.set(values: rowsAndId,
             cellClass: DiscoverySelectableRowCell.self,
             inSection: Section.favorites.rawValue)
  }

  internal func load(categoryRows rows: [ExpandableRow], categoryId: Int?) {
    self.set(values: [(title: Strings.discovery_filters_categories_title(), categoryId: categoryId)],
             cellClass: DiscoveryFiltersStaticRowCell.self,
             inSection: Section.categoriesHeader.rawValue)

    self.clearValues(section: Section.categories.rawValue)

    for row in rows {
      self.appendRow(
        value: (row: row, categoryId: categoryId),
        cellClass: DiscoveryExpandableRowCell.self,
        toSection: Section.categories.rawValue
      )

      if row.isExpanded {
        for selectableRow in row.selectableRows {
          self.appendRow(
            value: (row: selectableRow, categoryId: categoryId),
            cellClass: DiscoveryExpandedSelectableRowCell.self,
            toSection: Section.categories.rawValue
          )
        }
      }
    }
  }

  internal func selectableRow(indexPath indexPath: NSIndexPath) -> SelectableRow? {
    if let (row, _) = self[indexPath] as? (SelectableRow, Int?) {
      return row
    }
    return nil
  }

  internal func expandableRow(indexPath indexPath: NSIndexPath) -> ExpandableRow? {
    if let (row, _) = self[indexPath] as? (ExpandableRow, Int?) {
      return row
    }
    return nil
  }

  internal func indexPath(forCategoryId categoryId: Int?) -> NSIndexPath? {
    for (idx, value) in self[section: Section.categories.rawValue].enumerate() {
      guard let (row, _) = value as? (ExpandableRow, Int?) else { continue }
      if row.params.category?.id == categoryId {
        return NSIndexPath(forItem: idx, inSection: Section.categories.rawValue)
      }
    }

    return nil
  }

  internal func expandedRow() -> Int? {
    for (idx, value) in self[section: Section.categories.rawValue].enumerate() {
      guard let (row, _) = value as? (ExpandableRow, Int?) else { continue }

      if row.isExpanded {
        return idx
      }
    }

    return nil
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as DiscoverySelectableRowCell, value as (SelectableRow, Int?)):
      cell.configureWith(value: value)
    case let (cell as DiscoveryExpandableRowCell, value as (ExpandableRow, Int?)):
      cell.configureWith(value: value)
    case let (cell as DiscoveryExpandedSelectableRowCell, value as (SelectableRow, Int?)):
      cell.configureWith(value: value)
    case let (cell as DiscoveryFiltersStaticRowCell, value as (String, Int?)):
      cell.configureWith(value: value)
      return
    default:
      fatalError("Unrecognized combo (\(cell), \(value)).")
    }
  }
}
