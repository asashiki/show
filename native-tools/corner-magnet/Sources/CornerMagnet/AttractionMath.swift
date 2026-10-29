import CoreGraphics

enum AttractionMath {
    /// Returns a bounded, eased pointer position when the user is already moving toward a target.
    /// No result means the pointer should be left untouched.
    static func nextPoint(
        current: CGPoint,
        previous: CGPoint,
        target: CGPoint,
        radius: CGFloat,
        strength: CGFloat,
        snapDistance: CGFloat = 4
    ) -> CGPoint? {
        let toTarget = CGVector(dx: target.x - current.x, dy: target.y - current.y)
        let distance = hypot(toTarget.dx, toTarget.dy)
        guard distance > snapDistance, distance <= radius else { return nil }

        let movement = CGVector(dx: current.x - previous.x, dy: current.y - previous.y)
        let movementLength = hypot(movement.dx, movement.dy)
        guard movementLength > 0.5 else { return nil }

        // A positive dot product means the current movement is generally toward the target.
        let toward = movement.dx * toTarget.dx + movement.dy * toTarget.dy
        guard toward > 0 else { return nil }

        let amount = min(max(strength, 0), 0.35)
        guard amount > 0 else { return nil }

        return CGPoint(
            x: current.x + toTarget.dx * amount,
            y: current.y + toTarget.dy * amount
        )
    }
}
