//
//  ViewController.swift
//  LastApp
//
//  Created by cmStudent on 2021/11/07.
//

import UIKit
import RealityKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    /// 二つのボタンが配置されているStackView
    @IBOutlet private weak var HairCustomStackView: UIStackView!
    /// バツボタンのStackView
    @IBOutlet private weak var dismissStackView: UIStackView!
    /// モデル一覧を表示するCollecionView
    @IBOutlet private weak var hairModelListCollectionView: UICollectionView!
    /// モデルの写真一覧を格納する配列
    private let HairModelList = ["palette48","face48","back48", "palette36", "palette24"]
    /// モデルの一覧を格納する配列
    private let HairModel = ["face", "hair"]
    /// 画面幅
    private let width = UIScreen.main.bounds.width
    /// UIColorPickerViewControllerのインスタンス
    private let colorPicker = UIColorPickerViewController()
    /// ARViewのインスタンス
    private let arView = ARView()
    /// usdzModlを格納する
    private var hairModel = ModelEntity()
    /// Modelのidを保持
    private var modelID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        setUpARView()
        showModel(id: modelID)
        setUpHairModelListCollectionView(hairModelListCollectionView)
    }
    /// 初期設定
    private func setUp() {
        colorPicker.delegate = self
        colorPicker.supportsAlpha = false
        self.dismissStackView.isHidden = true
        self.hairModelListCollectionView.isHidden = true
    }
    /// ARViewの設定
    private func setUpARView() {
        arView.frame = CGRect(x: 0, y: 0, width: width, height: UIScreen.main.bounds.height/1.4);
        self.view.addSubview(arView)
    }
    /// HairModelListCollectionViewの設定
    private func setUpHairModelListCollectionView(_ collectionView: UICollectionView) {
        hairModelListCollectionView.dataSource = self
        hairModelListCollectionView.delegate   = self
        hairModelListCollectionView.register(UINib(nibName: HairModelCell.reuseIdentifier, bundle: nil),
                                             forCellWithReuseIdentifier: HairModelCell.reuseIdentifier)
        hairModelListCollectionView.collectionViewLayout = createHairModelCellLayout()
    }
    /// hairModel選択ボタン
    @IBAction private func tappedHairStyleButton(_ sender: UIButton) {
        self.dismissStackView.isHidden = false
        self.hairModelListCollectionView.isHidden = false
        self.HairCustomStackView.isHidden = true
        
        self.hairModelListCollectionView.alpha = 0.0
        self.dismissStackView.alpha = 0.0
        // CollectionViewのアニメーション
        UIView.animate(withDuration: 0.6, delay: 0, options: [.curveEaseIn], animations: {
            self.hairModelListCollectionView.alpha = 1.0
            self.dismissStackView.alpha = 1.0
        }, completion: nil)
    }
    /// hairModelの髪色選択ボタン
    @IBAction private func tappedHairColorButton(_ sender: UIButton) {
        showColorPicker()
    }
    /// Xボタン
    @IBAction private func tappedDismissButton(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.dismissStackView.isHidden = true
            self.hairModelListCollectionView.isHidden = true
            self.HairCustomStackView.isHidden = false
        }
    }
}

extension ViewController {
    
    private func createHairModelCellLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3),
                                               heightDimension: .fractionalHeight(1.0))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        // 個々のカラムのスペース
        let spacing = CGFloat(0)
        
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = spacing
        section.orthogonalScrollingBehavior = .continuous
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
        
    }
    
    /// usdzModel表示
    private func showModel(id: Int) {
        // ARViewのアンカーの削除
        arView.scene.anchors.removeAll()
        /// anchorのインスタンス(ARモデルを固定する錨)
        let anchor = AnchorEntity()
        // anchorの位置を設定
        anchor.position = simd_make_float3(0, -1.2, 0)
        // modelのidを格納
        modelID = id
        // usdzを読み込む
        hairModel = try! Entity.loadModel(named: HairModel[modelID])
        // ModelEntitiyに衝突形状をインストール
        hairModel.generateCollisionShapes(recursive: true)
        // ARViewにジェスチャーをインストール
        arView.installGestures(.all, for: hairModel)
        // アンカーの子階層にusdzModelを加える
        anchor.addChild(hairModel)
        // ARViewにアンカーの追加
        arView.scene.anchors.append(anchor)
    }
    
    /// usdzModelの色変更
    private func changeModelColor(color: UIColor) {
        // usdzのマテリアルの数だけ貼り付ける
        for index in 0 ..< hairModel.model!.mesh.expectedMaterialCount {
            // 青色、粗さ0、メタリックのシンプルなマテリアル
            let material = SimpleMaterial(color: color, roughness: 0, isMetallic: false)
            hairModel.model?.materials[index] = material
        }
    }
    
    /// UIColorPickerを呼び出す
    private func showColorPicker(){
        self.present(colorPicker, animated: true, completion: nil)
    }
    
}

extension ViewController: UICollectionViewDataSource {
    // セルの数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return HairModelList.count
    }
    /// セルの設定
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HairModelCell.reuseIdentifier, for: indexPath) as! HairModelCell
        cell.setUpHairModelCell(hairImage: HairModelList[indexPath.row])
        return cell
    }
    // セルがタップされたとき
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showModel(id: indexPath.row)
    }
}

extension ViewController: UIColorPickerViewControllerDelegate {
    // 色を選択したときの処理
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        changeModelColor(color: viewController.selectedColor)
    }
    // カラーピッカーを閉じたときの処理
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
    }
}

extension ViewController: UICollectionViewDelegate {
}
