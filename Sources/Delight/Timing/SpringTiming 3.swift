//
//  SpringContainer.swift
//  Delight
//
//  Created by Hector Matos on 11/17/18.
//

public struct SpringTiming {
    public let mass = 1.0
    public let damping = 10.0
    public let stiffness = 100.0
    public let velocity = 0.0
}

extension SpringTiming: TimingParameters {
    public func progress(at time: Double) -> Progress<Double> {
        guard damping > 0.0 && stiffness > 0.0 && mass > 0.0 else {
            fatalError("Incorrect animation values")
        }

        let beta = damping / (2 * mass)
        let omega0 = sqrt(stiffness / mass)
        let omega1 = sqrt((omega0 * omega0) - (beta * beta))
        let omega2 = sqrt((beta * beta) - (omega0 * omega0))

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
