import AppKit
import QuartzCore

class SpringAnimator {
    static func animateSpring(
        layer: CALayer,
        keyPath: String,
        from fromValue: Any?,
        to toValue: Any,
        stiffness: Double = 300,
        damping: Double = 20,
        mass: Double = 1,
        initialVelocity: Double = 0,
        completion: (() -> Void)? = nil
    ) {
        let animation = CASpringAnimation(keyPath: keyPath)
        
        animation.fromValue = fromValue
        animation.toValue = toValue
        
        animation.damping = damping
        animation.stiffness = stiffness
        animation.mass = mass
        animation.initialVelocity = initialVelocity
        
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        if let duration = animation.settlingDuration as Double? {
            animation.duration = duration
        } else {
            animation.duration = 0.5
        }
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        layer.add(animation, forKey: "\(keyPath)_spring")
        CATransaction.commit()
    }
    
    static func animateSpringTransform(
        layer: CALayer,
        to transform: CATransform3D,
        stiffness: Double = 300,
        damping: Double = 20,
        completion: (() -> Void)? = nil
    ) {
        animateSpring(
            layer: layer,
            keyPath: "transform",
            from: nil,
            to: NSValue(caTransform3D: transform),
            stiffness: stiffness,
            damping: damping,
            completion: completion
        )
    }
    
    static func animateSpringScale(
        layer: CALayer,
        to scale: CGFloat,
        stiffness: Double = 300,
        damping: Double = 20,
        completion: (() -> Void)? = nil
    ) {
        animateSpring(
            layer: layer,
            keyPath: "transform.scale",
            from: layer.presentation()?.value(forKeyPath: "transform.scale") ?? 1.0,
            to: scale,
            stiffness: stiffness,
            damping: damping,
            completion: completion
        )
    }
    
    static func animateSpringPosition(
        layer: CALayer,
        to position: CGPoint,
        stiffness: Double = 300,
        damping: Double = 20,
        completion: (() -> Void)? = nil
    ) {
        animateSpring(
            layer: layer,
            keyPath: "position",
            from: nil,
            to: NSValue(point: position),
            stiffness: stiffness,
            damping: damping,
            completion: completion
        )
    }
    
    static func animateSpringOpacity(
        layer: CALayer,
        to opacity: Float,
        stiffness: Double = 300,
        damping: Double = 20,
        completion: (() -> Void)? = nil
    ) {
        animateSpring(
            layer: layer,
            keyPath: "opacity",
            from: nil,
            to: opacity,
            stiffness: stiffness,
            damping: damping,
            completion: completion
        )
    }
}
