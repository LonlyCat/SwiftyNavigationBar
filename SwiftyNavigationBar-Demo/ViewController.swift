//
//  ViewController.swift
//  SwiftyNavigationBar
//
//  Created by meyoutao-3 on 2018/3/19.
//  Copyright © 2018年 meyoutao-3. All rights reserved.
//

import UIKit
import SwiftyNavigationBar

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Home"
        self.sn.barTintColor = nil
        self.sn.tintColor = UIColor.black
        self.sn.shadowColor = UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)

        let vc = UIViewController()
        vc.view.backgroundColor = .white
        vc.sn.barTintColor = UIColor.white
        vc.sn.shadowColor = UIColor.brown
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = scrollView.contentOffset
        if point.y >= -(self.sn.navHeight - 20) {
//            self.sn.barTintColor = nil
//            self.sn.shadowColor = UIColor.blue
        }
        else {
//            self.sn.barTintColor = UIColor.white
//            self.sn.shadowColor = nil
        }
    }
}

