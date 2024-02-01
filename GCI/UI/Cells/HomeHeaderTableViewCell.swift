//
//  HomeHeaderTableViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 07/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class HomeHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblLastSynch: UILabel!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var collectionViewFilter: UICollectionView!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var imgFilterActive: UIImageView!
    
    let configuration = AppDynamicConfiguration.current()
    let collectionInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
    let itemsPerRow: CGFloat = 3.0
    let horizontalSpaceBertweenItem: CGFloat = 7.0
    let verticalSpaceBertweenItem: CGFloat = 7.0
    var categories = [TaskCategory]()
    var taskList = [TaskViewModel]()
    var user = User.currentUser()
    var selectedCell = UICollectionViewCell()
    var onSelectCategory: ((_ category: TaskCategory?) -> Void)?
    var onTouchFilters: (() -> Void)?
    var selectedCategory: TaskCategory?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setInterface()
        setText()
        configureCollectionView()
        
        self.collectionViewFilter.dataSource = self
        self.collectionViewFilter.delegate = self
    }
    
    func setInterface() {
        self.backgroundColor = UIColor.lightPeriwinkle
        self.viewHeader.backgroundColor = configuration?.mainColor ?? UIColor.cerulean

        if let logoStringURL = configuration?.logoUrl, let imgLogoName = URL(string: logoStringURL)?.lastPathComponent {
            let path = FileManager.default.getDocumentsDirectoryURL().appendingPathComponent("\(imgLogoName).jpg")
            let fileStillExist = (try? path.checkResourceIsReachable()) ?? false
            if fileStillExist {
                self.imgLogo.image = UIImage(contentsOfFile: path.absoluteString.replacingOccurrences(of: "file:///", with: ""))
            } else {
                var header: HTTPHeaders = [:]
                if let key = KeychainManager.shared.licenceKey {
                    header[Constant.API.HeadersName.apiKey] = key
                }
                
                if let urlString = configuration?.logoUrl {
                    AF.request(urlString,
                                      method: .get,
                                      parameters: nil,
                                      encoding: URLEncoding.default,
                                      headers: header).validate().responseData { response in
                                        if let imageData = response.data, let image = UIImage(data: imageData) {
                                            _ = image.saveImageInDisk(withName: imgLogoName)
                                            self.imgLogo.image = image
                                        }
                    }
                }
            }
        }
        
        self.viewHeader.addShadow()
    }
    
    func setText() {
        self.lblTitle.font = UIFont.gciFontBold(19)
        self.lblLastSynch.font = UIFont.gciFontRegular(12)
        
        self.lblTitle.textColor = UIColor.white
        self.lblLastSynch.textColor = UIColor.white
    }
    
    func setCell(withTaskCategories categories: [TaskCategory], forTaskList tasks: [TaskViewModel], isFilterActive: Bool = false, categorySelected: TaskCategory? = nil, withTitle title: String = "dashboard_title".localized) {
        self.categories = categories
        self.taskList = tasks
        self.collectionViewFilter.reloadData()
        if let dateLastRequest = UserDefaultManager.shared.lastTaskListRequestDate {
            self.lblLastSynch.text = "dashboard_last_sync".localized(arguments: dateLastRequest.toDateString(style: .short), dateLastRequest.toTimeString(style: .medium))
        } else {
            self.lblLastSynch.text = ""
        }
        
        self.btnFilter.setImage(UIImage(named: "ico_white_filter"), for: .normal)
        self.imgFilterActive.isHidden = !isFilterActive
        self.selectedCategory = categorySelected
        
        self.lblTitle.text = title
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnFiltersTouched(_ sender: Any) {
        self.onTouchFilters?()
    }
}

extension HomeHeaderTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func configureCollectionView() {
        self.collectionViewFilter.backgroundColor = UIColor.clear
        
        self.collectionViewFilter.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.collectionViewFilter.register(UINib(nibName: "HomeTaskTypeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeTaskTypeCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeTaskTypeCell", for: indexPath) as! HomeTaskTypeCollectionViewCell
        if let user = User.currentUser() {
            
            var isSelected = false
            if selectedCategory == categories[indexPath.row] {
                self.selectedCell = cell
                isSelected = true
            } else {
                isSelected = false
            }
            
            let taskListFiltered = taskList.filter({ $0.category(forUser: user) == categories[indexPath.row] })
            cell.setCell(withCategory: categories[indexPath.row], numberOfTask: taskListFiltered.count, numberOfTaskToday: taskListFiltered.updatedTodayCount, isSelectCategory: isSelected)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UICollectionView.itemSize(totalWidth: self.collectionViewFilter.frame.width, itemsPerRow: itemsPerRow, collectionInsets: collectionInsets, horizontalSpaceBetweenItem: horizontalSpaceBertweenItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return collectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return verticalSpaceBertweenItem
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            if selectedCell == cell {
                collectionView.deselectItem(at: indexPath, animated: true)
                selectedCell = UICollectionViewCell()
                if let onSelectCategory = onSelectCategory {
                    onSelectCategory(nil)
                }
            } else {
                if let selectedCell = selectedCell as? HomeTaskTypeCollectionViewCell, let index = self.collectionViewFilter.indexPath(for: selectedCell) {
                    collectionView.deselectItem(at: index, animated: false)
//                    cell.isSelected = false
                }
                
                selectedCell = cell
                if let onSelectCategory = onSelectCategory {
                    onSelectCategory(categories[indexPath.row])
                }
            }
        }
    }
} 
