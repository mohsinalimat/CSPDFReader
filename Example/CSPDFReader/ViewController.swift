//
//  ViewController.swift
//  CSPDFReader
//
//  Created by WeiRuJian on 11/13/2018.
//  Copyright (c) 2018 WeiRuJian. All rights reserved.
//

import UIKit
import CSPDFReader

class ViewController: UIViewController {

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    private var images: [UIImage] = [] {
        didSet{
            self.collectionView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        guard let reader = CSPDFReader(url: URL(string: "http://into.wainwar.com/upload/UserPaper/13977823556/pdf/201811/12/201811121156569793/201811121156569793.pdf")!) else { print("初始化PDFReader失败"); return }
        
//        let url = URL(string: "http://into.wainwar.com/upload/UserPaper/13977823556/pdf/201811/12/201811121156569793/201811121156569793.pdf")!
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "图解HTTP", ofType: "pdf")!)
       guard let reader =  CSPDFReader(url: url,
                                       constant: 300) else { print("初始化PDFReader失败"); return }
        print("总页数: \(reader.pageCount)")
        print("文件名称: \(reader.fileName)")
        guard let images =  reader.allPageImages() else { print("没有图片"); return }
        
        dump(images)
        
        self.images = images
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailCell", for: indexPath) as! ThumbnailCell
        
        cell.imageView.image = self.images[indexPath.row]
        
        return cell
    }
}

class ThumbnailCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
