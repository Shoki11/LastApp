//
//  ViewController.swift
//  LastApp
//
//  Created by cmStudent on 2021/11/07.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    // MARK: - @IBOutlets
    /// 二つのボタンが配置されているStackView
    @IBOutlet private weak var HairCustomStackView: UIStackView!
    /// バツボタンのStackView
    @IBOutlet private weak var dismissStackView: UIStackView!
    /// Model回転のボタン
    @IBOutlet private weak var rotationButton: UIButton!
    /// モデル一覧を表示するCollecionView
    @IBOutlet private weak var hairModelListCollectionView: UICollectionView!
    
    // MARK: - Propeties
    /// モデルの写真一覧を格納する配列
    private let HairModelList = ["face", "men01", "women01", "face48", "back48", "rotation48"]
    /// モデルの一覧を格納する配列
    private let HairModel = ["face", "men01", "women01", "hair"]
    /// 画面幅
    private let width = UIScreen.main.bounds.width
    /// 画面の高さ
    private let height = UIScreen.main.bounds.height/1.4
    /// UIColorPickerViewControllerのインスタンス
    private let colorPicker = UIColorPickerViewController()
    /// ARViewのインスタンス
    private let arView = ARView()
    /// マネキンのモデルを格納する
    private var faceModel = ModelEntity()
    /// usdzModlを格納する
    private var hairModel = ModelEntity()
    /// anchorのインスタンス
    private var passAnchor = AnchorEntity()
    /// faceModelのマテリアル
    private var faceMaterial = SimpleMaterial(color: .white, roughness: 0.35, isMetallic: false)
    /// hairModelのマテリアル
    private var hairMaterial = SimpleMaterial(color: .black, roughness: 0.35, isMetallic: false)
    /// Modelのidを保持
    private var modelID = 0
    
    // MARK: - Methods
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
        arView.frame = CGRect(x: 0, y: 0, width: width, height: height);
        self.view.addSubview(arView)
    }
    
    /// HairModelListCollectionViewの設定
    /// - Parameter collectionView: 設定したいCollectionView
    private func setUpHairModelListCollectionView(_ collectionView: UICollectionView) {
        hairModelListCollectionView.dataSource = self
        hairModelListCollectionView.delegate   = self
        hairModelListCollectionView.register(UINib(nibName: HairModelCell.reuseIdentifier, bundle: nil),
                                             forCellWithReuseIdentifier: HairModelCell.reuseIdentifier)
        hairModelListCollectionView.collectionViewLayout = createHairModelCellLayout()
    }
    
    /// usdzModel表示
    /// - Parameter id: HairModelのid
    private func showModel(id: Int) {
        // ARViewのアンカーの削除
        arView.scene.anchors.removeAll()
        /// anchorのインスタンス(ARモデルを固定する錨)
        let anchor = AnchorEntity()
        /// usdzModelの角度
        let degree: Float = 10 * 180 / .pi
        // anchorの位置を設定
        anchor.position = simd_make_float3(0.01, -1.05, 0.2)
        // y軸にdegree分回転
        anchor.orientation = simd_quatf(angle: degree, axis: [0,1,0])
        // modelのidを格納
        modelID = id
        
        if id == 0 {
            // usdzを読み込む
            faceModel = try! Entity.loadModel(named: "face")
            // マネキンのusdzのマテリアルの数だけ貼り付ける
            for index in 0 ..< faceModel.model!.mesh.expectedMaterialCount {
                faceModel.model?.materials[index] = faceMaterial
            }
            // アンカーの子階層にusdzModelを加える
            anchor.addChild(faceModel)
        } else {
            // usdzを読み込む
            faceModel = try! Entity.loadModel(named: "face")
            hairModel = try! Entity.loadModel(named: HairModel[modelID])
            // マネキンのusdzのマテリアルの数だけ貼り付ける
            for index in 0 ..< faceModel.model!.mesh.expectedMaterialCount {
                faceModel.model?.materials[index] = faceMaterial
            }
            // 髪型のusdzのマテリアルの数だけ貼り付ける
            for index in 0 ..< hairModel.model!.mesh.expectedMaterialCount {
                hairModel.model?.materials[index] = hairMaterial
            }
            // アンカーの子階層にusdzModelを加える
            anchor.addChild(faceModel)
            anchor.addChild(hairModel)
        }
        // ARViewにアンカーの追加
        arView.scene.anchors.append(anchor)
        // 回転メソッドに渡すanchorに格納
        passAnchor = anchor
    }
    
    /// usdzModelの色変更
    /// - Parameter id: HairModelのid
    /// - Parameter color: 設定したい色
    private func changeModelColor(id: Int, color: UIColor) {
        if id == 0 {
            // usdzのマテリアルの数だけ貼り付ける
            for index in 0 ..< faceModel.model!.mesh.expectedMaterialCount {
                // 色、粗さ0、メタリックのシンプルなマテリアル
                let material = SimpleMaterial(color: color, roughness: 0.35, isMetallic: false)
                faceModel.model?.materials[index] = material
                // 選択した色を記録
                faceMaterial = material
            }
        } else {
            // usdzのマテリアルの数だけ貼り付ける
            for index in 0 ..< hairModel.model!.mesh.expectedMaterialCount {
                // 色、粗さ0、メタリックのシンプルなマテリアル
                let material = SimpleMaterial(color: color, roughness: 0.35, isMetallic: false)
                hairModel.model?.materials[index] = material
                // 選択した色を記録
                hairMaterial = material
            }
        }
    }
    
    /// UIColorPickerを呼び出す
    private func showColorPicker(){
        self.present(colorPicker, animated: true, completion: nil)
    }
    
    /// usdzModelの回転
    /// - Parameter anchor: 回転したいanchor
    private func rotationAnchor(anchor: AnchorEntity) {
        // rotationButtonを非活性
        rotationButton.isEnabled = false
        /// 回す角度
        let firstRotation: Float = 180 * .pi / 180
        let secondRotation: Float = 179 * .pi / 180
        // Y軸で180°回転する
        anchor.move(to: Transform(pitch: 0, yaw: firstRotation, roll: 0), relativeTo: anchor, duration: 7)
        // 5.6秒後に実行
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            // Y軸で180°回転する
            anchor.move(to: Transform(pitch: 0, yaw: secondRotation, roll: 0), relativeTo: anchor, duration: 7)
            // 5.6秒後に実行
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                // rotationButoonを活性
                self.rotationButton.isEnabled = true
            }
        }
    }
    
    // MARK: - IBActions
    /// hairModel選択ボタン
    @IBAction private func tappedHairStyleButton(_ sender: UIButton) {
        self.dismissStackView.isHidden = false
        self.hairModelListCollectionView.isHidden = false
        self.HairCustomStackView.isHidden = true
        // 透明度0にして非表示
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
    /// usdzModelの回転
    @IBAction private func tappedModelRotation(_ sender: UIButton) {
        rotationAnchor(anchor: passAnchor)
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

// MARK: - Layout
extension ViewController {
    /// HairModelの画像を表示するレイアウト
    /// - Returns: HairModelの画像を表示するレイアウト
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
        // 横スクロール
        section.orthogonalScrollingBehavior = .continuous
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
}

// MARK: - UICollectionViewDataSource
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

// MARK: - UIColorPickerViewControllerDelegate
extension ViewController: UIColorPickerViewControllerDelegate {
    // 色を選択したときの処理
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        changeModelColor(id: modelID, color: viewController.selectedColor)
    }
    // カラーピッカーを閉じたときの処理
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {}
}

// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {}
