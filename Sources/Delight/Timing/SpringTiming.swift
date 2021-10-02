import Foundation
import Numerics

public struct SpringTiming {
    public let mass = 1.0
    public let damping = 10.0
    public let stiffness = 100.0
    public let velocity = 0.0
}

extension SpringTiming: TimingParameters {
    public func progress(at time: Double) -> Progress {
        guard damping > 0.0 && stiffness > 0.0 && mass > 0.0 else {
            fatalError("Incorrect animation values")
        }

        let beta = damping / (2 * mass)
        let omega0 = (√(stiffness / mass)).real
        let omega1 = (√(omega0^^2 - beta^^2)).real
        let omega2 = (√(beta^^2 - omega0^^2)).real

        let x0 = -1.0
        let relativeValue: Double

        if beta < omega0 {
            // Underdamped
            let envelope = exp(-beta * time)

            let part2 = x0 * cos(omega1 * time)
            let part3 = ((beta * x0 + velocity) / omega1) * sin(omega1 * time)
            relativeValue = -x0 + envelope * (part2 + part3)
        } else if beta == omega0 {
            // Critically damped
            let envelope = exp(-beta * time)
            relativeValue = -x0 + envelope * (x0 + (beta * x0 + velocity) * time)
        } else {
            // Overdamped
            let envelope = exp(-beta * time)
            let part2 = x0 * cosh(omega2 * time)
            let part3 = ((beta * x0 + velocity) / omega2) * sinh(omega2 * time)
            relativeValue = -x0 + envelope * (part2 + part3)
        }

        return Progress(relativeTime: time, relativeValue: relativeValue)
    }
}
