//
//  UIStackView+Extension.swift
//  FireApp
//
//  Created by Pavel Bogart on 23/02/2018.
//  Copyright © 2018 Pavel Bogart. All rights reserved.
//

import UIKit

extension UIView {
    func createStackView(views: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        return stackView
    }
}
