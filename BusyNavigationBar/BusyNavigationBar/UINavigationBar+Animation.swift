//
//  UINavigationBar+Animation.swift
//  BusyNavigationBar
//
//  Created by Gunay Mert Karadogan on 22/7/15.
//  Copyright (c) 2015 Gunay Mert Karadogan. All rights reserved.
//

import UIKit

private var BusyNavigationBarLoadingLayerAssociationKey: UInt8 = 0
private var BusyNavigationBarOptionsAssociationKey: UInt8 = 1
private var alphaAnimationDurationOfLoadingView = 0.3

extension UINavigationBar {

    // MARK: - Properties
    private var busy_loadingLayer: CALayer? {
        get {
            return objc_getAssociatedObject(self, &BusyNavigationBarLoadingLayerAssociationKey) as? CALayer
        }
        set {
            objc_setAssociatedObject(self, &BusyNavigationBarLoadingLayerAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    private var busy_options: BusyNavigationBarOptions {
        get {
            return objc_getAssociatedObject(self, &BusyNavigationBarOptionsAssociationKey) as! BusyNavigationBarOptions
        }
        set {
            objc_setAssociatedObject(self, &BusyNavigationBarOptionsAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    // MARK: - Overrides

    public override var bounds: CGRect {
        didSet {
            guard oldValue != bounds,
                let loadingLayer = busy_loadingLayer else { return }

            loadingLayer.removeFromSuperlayer()
            busy_loadingLayer = nil
            start(busy_options)
        }
    }

    // MARK: - Tasks

    public func start(options: BusyNavigationBarOptions? = nil) {
        // remove previous layer
        busy_loadingLayer?.removeFromSuperlayer()

        busy_options = options ?? BusyNavigationBarOptions()

        let animationLayer = pickAnimationLayer
        animationLayer.masksToBounds = true
        animationLayer.position.x = bounds.size.width / 2
        animationLayer.position.y = bounds.size.height / 2

        if busy_options.transparentMaskEnabled {
            animationLayer.mask = maskLayer
        }

        // Add the busy_loadingLayer directly as sublayer
        layer.addSublayer(animationLayer)
        busy_loadingLayer = animationLayer

        setLayerHiddenAnimated(hidden: false)
    }

    public func stop() {
        setLayerHiddenAnimated(hidden: true)
    }

    // MARK: - Private

    private func setLayerHiddenAnimated(hidden hidden: Bool) {
        let opacity = hidden ? 0 : Float(busy_options.alpha)

        UIView.animateWithDuration(alphaAnimationDurationOfLoadingView,
            delay: 0,
            options: [.AllowUserInteraction],
            animations: {
                self.busy_loadingLayer?.opacity = opacity
            },
            completion: nil)
    }

    private var pickAnimationLayer: CALayer {
        switch busy_options.animationType {
        case .Stripes:
            return AnimationLayerCreator.stripeAnimationLayer(bounds, options: busy_options)
        case .Bars:
            return AnimationLayerCreator.barAnimation(bounds, options: busy_options)
        case .CustomLayer(let layerCreator):
            return layerCreator()
        }
    }

    private var maskLayer: CALayer {
        let alphaLayer = CAGradientLayer()
        alphaLayer.frame = bounds
        alphaLayer.colors = [
            UIColor.clearColor().CGColor,
            UIColor(white: 0, alpha: 0.2).CGColor]

        return alphaLayer
    }
}
