//
//  TypesOfLeavesViewController.swift
//  HR
//
//  Created by Esther Elzek on 28/09/2025.
//

import UIKit

struct StateType {
    let title: String
    let key: String   // "refuse", "confirm", "validate"
}

class TypesOfLeavesViewController: UIViewController {
    
    @IBOutlet weak var leaveTypesCollectionView: UICollectionView!
    @IBOutlet weak var statesTypesCollectionView: UICollectionView!
    
    let viewModel = TimeOffViewModel()
    var leaveTypes: [LeaveType] = []
    
    // ✅ Predefined states
    let stateTypes: [StateType] = [
        StateType(title: "Refused", key: "refuse"),
        StateType(title: "Confirmed", key: "confirm"),
        StateType(title: "Validated", key: "validate")
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leaveTypesCollectionView.delegate = self
        leaveTypesCollectionView.dataSource = self
        
        statesTypesCollectionView.delegate = self
        statesTypesCollectionView.dataSource = self
        
        leaveTypesCollectionView.register(UINib(nibName: "TypesOfLeavesCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "TypesOfLeavesCollectionViewCell")
        statesTypesCollectionView.register(UINib(nibName: "TypesOfLeavesCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "TypesOfLeavesCollectionViewCell")
        loadTimeOffData() {}
       
    }
    
    private func loadTimeOffData(completion: @escaping () -> Void) {
        guard let token = UserDefaults.standard.employeeToken else { return completion() }
        viewModel.fetchTimeOff(token: token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let leaveTypes = response.result?.leaveTypes {
                        self?.leaveTypes = leaveTypes
                        self?.leaveTypesCollectionView.reloadData()
                        self?.statesTypesCollectionView.reloadData()
                    }
                case .failure(let error):
                    print("❌ TimeOff API Error:", error)
                }
                completion()
            }
        }
    }
}

extension TypesOfLeavesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == leaveTypesCollectionView {
            return leaveTypes.count
        } else {
            return stateTypes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "TypesOfLeavesCollectionViewCell",
            for: indexPath
        ) as? TypesOfLeavesCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if collectionView == leaveTypesCollectionView {
            let leaveType = leaveTypes[indexPath.item]
            cell.titleLabel.text = leaveType.name
            cell.coloredButton.backgroundColor = .systemBlue
        } else {
            let state = stateTypes[indexPath.item]
            cell.titleLabel.text = state.title
            cell.configureState(for: state.key) // 👈 add drawing
        }
        
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 30)
    }
}
