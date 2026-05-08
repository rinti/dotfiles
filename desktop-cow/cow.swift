import SwiftUI
import AppKit

// MARK: - Appearance

struct SpotConfig {
    var center: CGPoint   // normalized 0..1 inside container
    var size: CGSize      // normalized fraction of container
    var rotation: Double  // degrees
    var phase: Double     // varies blob shape
}

struct CowAppearance {
    var darkColor: Color           // spots, tail, back ear
    var bodySpots: [SpotConfig]
    var headSpot: SpotConfig?
    var hasHorns: Bool
    var sizeMultiplier: CGFloat

    static func random() -> CowAppearance {
        // Black is most common (real Holsteins), brown variants for variety.
        let palette: [Color] = [
            Color(white: 0.1),
            Color(white: 0.1),
            Color(white: 0.1),
            Color(red: 0.28, green: 0.16, blue: 0.1),
            Color(red: 0.5, green: 0.28, blue: 0.18),
            Color(red: 0.35, green: 0.22, blue: 0.15)
        ]

        let count = Int.random(in: 4...6)
        let bodySpots = (0..<count).map { _ in
            SpotConfig(
                center: CGPoint(
                    x: .random(in: 0.1...0.9),
                    y: .random(in: 0.2...0.8)
                ),
                size: CGSize(
                    width: .random(in: 0.13...0.28),
                    height: .random(in: 0.22...0.42)
                ),
                rotation: .random(in: -50...50),
                phase: .random(in: 0...100)
            )
        }

        let headSpot: SpotConfig? = Bool.random() ? SpotConfig(
            center: CGPoint(
                x: .random(in: 0.3...0.55),
                y: .random(in: 0.35...0.55)
            ),
            size: CGSize(
                width: .random(in: 0.4...0.6),
                height: .random(in: 0.3...0.45)
            ),
            rotation: .random(in: -25...25),
            phase: .random(in: 0...100)
        ) : nil

        return CowAppearance(
            darkColor: palette.randomElement()!,
            bodySpots: bodySpots,
            headSpot: headSpot,
            hasHorns: Double.random(in: 0...1) < 0.7,
            sizeMultiplier: 1.0
        )
    }
}

// MARK: - State

struct HayBale: Identifiable {
    let id = UUID()
    var position: CGPoint
    var assignedCowId: UUID?
}

@MainActor
final class PastureModel: ObservableObject, Identifiable {
    enum CowState { case walking, grazing, following, headingToHay, eatingHay }

    /// Mouse must come within this distance (px) before the cow starts following.
    static let followStart: CGFloat = 80
    /// Once following, the cow stops following only after the mouse is this far away.
    static let followStop: CGFloat = 220
    /// Seconds spent eating each hay bale.
    static let eatingDuration: TimeInterval = 5.0

    let id = UUID()
    let appearance: CowAppearance
    weak var herd: Herd?

    @Published var x: CGFloat = 0
    @Published var y: CGFloat = 0
    @Published var facing: CGFloat = 1
    @Published var state: CowState = .walking
    @Published var legPhase: Double = 0
    @Published var bodyBob: Double = 0

    var hayTargetId: UUID?
    var hayTargetPos: CGPoint?

    private var targetX: CGFloat = 0
    private var targetY: CGFloat = 0
    private var bounds: CGSize = .zero
    private var cowSize: CGSize = .zero
    private var grazingUntil: Date = .distantPast
    private var eatingUntil: Date = .distantPast
    private var configured = false

    init(appearance: CowAppearance = .random()) {
        self.appearance = appearance
    }

    private var yMin: CGFloat { bounds.height / 3 }
    private var yMax: CGFloat { bounds.height - cowSize.height * 0.5 }

    /// Perspective scale: 1.0 at the bottom, 0.5 at yMin.
    var scale: CGFloat {
        guard yMax > yMin else { return 1 }
        let t = (y - yMin) / (yMax - yMin)
        let minScale: CGFloat = 0.5
        return minScale + (1 - minScale) * max(0, min(1, t))
    }

    func configure(bounds: CGSize, cowSize: CGSize) {
        self.bounds = bounds
        self.cowSize = cowSize
        guard !configured else { return }
        configured = true
        x = CGFloat.random(in: (cowSize.width * 0.5)...(bounds.width - cowSize.width * 0.5))
        y = CGFloat.random(in: yMin...yMax)
        legPhase = .random(in: 0...(2 * .pi))
        if Bool.random() {
            state = .grazing
            grazingUntil = Date().addingTimeInterval(.random(in: 1...6))
        }
        pickNewTarget()
    }

    func assignHay(id: UUID, position: CGPoint) {
        hayTargetId = id
        hayTargetPos = position
        state = .headingToHay
    }

    func tick(mouseLocation: CGPoint?) {
        let s = scale

        // Hay assignment overrides everything else.
        if hayTargetId != nil {
            switch state {
            case .eatingHay:
                handleEating()
            case .headingToHay:
                handleHeadingToHay(s: s)
            default:
                state = .headingToHay
                handleHeadingToHay(s: s)
            }
            return
        }

        // Mouse proximity drives the .following state.
        if let mouse = mouseLocation {
            let mdist = hypot(mouse.x - x, mouse.y - y)
            switch state {
            case .walking, .grazing:
                if mdist < Self.followStart { state = .following }
            case .following:
                if mdist > Self.followStop {
                    state = .walking
                    pickNewTarget()
                }
            case .headingToHay, .eatingHay:
                break
            }
        } else if state == .following {
            state = .walking
            pickNewTarget()
        }

        switch state {
        case .walking: handleWalking(s: s)
        case .grazing: handleGrazing()
        case .following:
            if let mouse = mouseLocation { handleFollowing(mouse: mouse, s: s) }
        case .headingToHay, .eatingHay:
            break
        }
    }

    private func handleWalking(s: CGFloat) {
        let dx = targetX - x
        let dy = targetY - y
        let dist = sqrt(dx * dx + dy * dy)

        if dist < 3 {
            state = .grazing
            grazingUntil = Date().addingTimeInterval(.random(in: 4...9))
            return
        }

        let speed: CGFloat = 1.4 * s
        x += (dx / dist) * speed
        y += (dy / dist) * speed
        facing = dx >= 0 ? 1 : -1
        legPhase += 0.18 * s
        bodyBob = sin(legPhase) * 0.6
    }

    private func handleGrazing() {
        if Date() > grazingUntil {
            pickNewTarget()
            state = .walking
        }
        bodyBob = sin(Date().timeIntervalSinceReferenceDate * 2.2) * 0.4
    }

    private func handleFollowing(mouse: CGPoint, s: CGFloat) {
        let xMargin = cowSize.width * 0.5
        let mx = max(xMargin, min(bounds.width - xMargin, mouse.x))
        let my = max(yMin, min(yMax, mouse.y))
        let dx = mx - x
        let dy = my - y
        let dist = sqrt(dx * dx + dy * dy)

        if dist > 3 {
            let speed: CGFloat = 1.4 * s
            x += (dx / dist) * speed
            y += (dy / dist) * speed
            facing = dx >= 0 ? 1 : -1
            legPhase += 0.18 * s
            bodyBob = sin(legPhase) * 0.6
        } else {
            bodyBob = sin(Date().timeIntervalSinceReferenceDate * 2.2) * 0.4
        }
    }

    private func handleHeadingToHay(s: CGFloat) {
        guard let hayPos = hayTargetPos else {
            hayTargetId = nil
            state = .walking
            pickNewTarget()
            return
        }

        let dx = hayPos.x - x
        let dy = hayPos.y - y
        let dist = sqrt(dx * dx + dy * dy)

        if dist < 5 {
            state = .eatingHay
            eatingUntil = Date().addingTimeInterval(Self.eatingDuration)
            return
        }

        let speed: CGFloat = 1.6 * s   // hungry — slightly faster
        x += (dx / dist) * speed
        y += (dy / dist) * speed
        facing = dx >= 0 ? 1 : -1
        legPhase += 0.2 * s
        bodyBob = sin(legPhase) * 0.6
    }

    private func handleEating() {
        if Date() > eatingUntil {
            if let hayId = hayTargetId {
                herd?.consumeHay(id: hayId)
            }
            hayTargetId = nil
            hayTargetPos = nil
            state = .walking
            pickNewTarget()
            return
        }
        bodyBob = sin(Date().timeIntervalSinceReferenceDate * 2.2) * 0.4
    }

    private func pickNewTarget() {
        let xMargin = cowSize.width * 0.5
        targetX = CGFloat.random(in: xMargin...(bounds.width - xMargin))
        targetY = CGFloat.random(in: yMin...yMax)
    }
}

// MARK: - Herd

@MainActor
final class Herd: ObservableObject {
    let cows: [PastureModel]
    @Published var hayBales: [HayBale] = []
    private var bounds: CGSize = .zero

    init(count: Int) {
        cows = (0..<count).map { _ in PastureModel() }
        for cow in cows { cow.herd = self }
    }

    func configure(bounds: CGSize, baseCowSize: CGSize) {
        self.bounds = bounds
        for cow in cows {
            let m = cow.appearance.sizeMultiplier
            cow.configure(
                bounds: bounds,
                cowSize: CGSize(
                    width: baseCowSize.width * m,
                    height: baseCowSize.height * m
                )
            )
        }
    }

    func tick(mouseLocation: CGPoint?) {
        for cow in cows {
            cow.tick(mouseLocation: mouseLocation)
        }
        // Force PastureView to re-evaluate so the y-sorted ForEach reorders cows.
        objectWillChange.send()
    }

    func dropHay(at point: CGPoint) {
        guard !cows.isEmpty, bounds.width > 0 else { return }

        let yMinHay = bounds.height / 3
        let yMaxHay = bounds.height - 30
        let xMargin: CGFloat = 30
        let clamped = CGPoint(
            x: max(xMargin, min(bounds.width - xMargin, point.x)),
            y: max(yMinHay, min(yMaxHay, point.y))
        )

        guard let nearest = cows.min(by: {
            hypot($0.x - clamped.x, $0.y - clamped.y) < hypot($1.x - clamped.x, $1.y - clamped.y)
        }) else { return }

        // Remove any orphaned hay this cow had previously been assigned.
        if let oldHayId = nearest.hayTargetId {
            hayBales.removeAll { $0.id == oldHayId }
        }

        let hay = HayBale(position: clamped, assignedCowId: nearest.id)
        hayBales.append(hay)
        nearest.assignHay(id: hay.id, position: clamped)
    }

    func consumeHay(id: UUID) {
        hayBales.removeAll { $0.id == id }
    }
}

// MARK: - Cow Drawing

struct CowSprite: View {
    let state: PastureModel.CowState
    let legPhase: Double
    let facing: CGFloat
    let bodyBob: Double
    let appearance: CowAppearance

    var body: some View {
        GeometryReader { geo in
            let W = geo.size.width
            let H = geo.size.height
            let isMoving = state == .walking || state == .following || state == .headingToHay
            let headDown = state == .grazing || state == .eatingHay

            ZStack {
                // Tail
                CowTail()
                    .stroke(appearance.darkColor, style: StrokeStyle(lineWidth: max(2, H * 0.022), lineCap: .round))
                    .frame(width: W * 0.16, height: H * 0.32)
                    .position(x: W * 0.13, y: H * 0.42 + bodyBob)

                Ellipse()
                    .fill(appearance.darkColor)
                    .frame(width: H * 0.09, height: H * 0.07)
                    .rotationEffect(.degrees(35))
                    .position(x: W * 0.06, y: H * 0.62 + bodyBob)

                // Back legs (behind body)
                Leg(phase: legPhase + .pi, isWalking: isMoving)
                    .frame(width: W * 0.05, height: H * 0.42)
                    .position(x: W * 0.27, y: H * 0.78)

                Leg(phase: legPhase, isWalking: isMoving)
                    .frame(width: W * 0.05, height: H * 0.42)
                    .position(x: W * 0.55, y: H * 0.78)

                // Body
                CowBody(appearance: appearance)
                    .frame(width: W * 0.7, height: H * 0.5)
                    .position(x: W * 0.42, y: H * 0.42 + bodyBob)

                // Udder
                Udder()
                    .frame(width: W * 0.13, height: H * 0.14)
                    .position(x: W * 0.4, y: H * 0.7 + bodyBob * 0.5)

                // Front legs (in front of body)
                Leg(phase: legPhase + .pi + 0.6, isWalking: isMoving)
                    .frame(width: W * 0.05, height: H * 0.42)
                    .position(x: W * 0.32, y: H * 0.78)

                Leg(phase: legPhase + 0.6, isWalking: isMoving)
                    .frame(width: W * 0.05, height: H * 0.42)
                    .position(x: W * 0.6, y: H * 0.78)

                // Head
                CowHead(grazing: headDown, appearance: appearance)
                    .frame(width: W * 0.36, height: H * 0.45)
                    .position(
                        x: W * 0.78,
                        y: headDown ? H * 0.8 : H * 0.32 + bodyBob
                    )
                    .animation(.easeInOut(duration: 0.45), value: headDown)
            }
            .scaleEffect(x: facing, y: 1)
        }
    }
}

struct CowTail: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.addCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY),
            control1: CGPoint(x: rect.midX + rect.width * 0.2, y: rect.midY * 0.4),
            control2: CGPoint(x: rect.minX - rect.width * 0.05, y: rect.midY * 1.1)
        )
        return p
    }
}

struct Leg: View {
    let phase: Double
    let isWalking: Bool

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let lift: CGFloat = isWalking ? CGFloat(max(0, sin(phase))) * h * 0.12 : 0

            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: w * 0.35)
                    .fill(
                        LinearGradient(
                            colors: [Color(white: 0.97), Color(white: 0.82)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: w, height: h * 0.85)

                RoundedRectangle(cornerRadius: w * 0.22)
                    .fill(
                        LinearGradient(
                            colors: [Color(white: 0.18), Color(white: 0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: w * 1.15, height: h * 0.18)
                    .offset(y: h * 0.78)
            }
            .offset(y: -lift)
        }
    }
}

struct CowBody: View {
    let appearance: CowAppearance

    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color(white: 0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            CowSpots(spots: appearance.bodySpots, color: appearance.darkColor)
        }
        .mask(Ellipse())
        .overlay(
            Ellipse()
                .stroke(Color(white: 0.6).opacity(0.35), lineWidth: 0.6)
        )
        .shadow(color: .black.opacity(0.18), radius: 6, x: 2, y: 4)
    }
}

struct CowSpots: View {
    let spots: [SpotConfig]
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let W = geo.size.width
            let H = geo.size.height

            ForEach(Array(spots.enumerated()), id: \.offset) { _, spot in
                Spot(phase: spot.phase)
                    .fill(color)
                    .frame(width: W * spot.size.width, height: H * spot.size.height)
                    .rotationEffect(.degrees(spot.rotation))
                    .position(x: W * spot.center.x, y: H * spot.center.y)
            }
        }
    }
}

/// Organic blob shape — phase varies the wobble pattern per spot.
struct Spot: Shape {
    let phase: Double

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX
        let cy = rect.midY
        let rx = rect.width / 2
        let ry = rect.height / 2
        let n = 10
        var pts: [CGPoint] = []
        for i in 0..<n {
            let angle = Double(i) / Double(n) * 2 * .pi
            let wobble = 0.82 + sin(angle * 3 + phase) * 0.18
            pts.append(CGPoint(
                x: cx + cos(angle) * rx * CGFloat(wobble),
                y: cy + sin(angle) * ry * CGFloat(wobble)
            ))
        }
        let firstMid = CGPoint(
            x: (pts[0].x + pts[n - 1].x) / 2,
            y: (pts[0].y + pts[n - 1].y) / 2
        )
        p.move(to: firstMid)
        for i in 0..<n {
            let curr = pts[i]
            let next = pts[(i + 1) % n]
            let mid = CGPoint(x: (curr.x + next.x) / 2, y: (curr.y + next.y) / 2)
            p.addQuadCurve(to: mid, control: curr)
        }
        p.closeSubpath()
        return p
    }
}

struct Udder: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 1.0, green: 0.82, blue: 0.85), Color(red: 0.95, green: 0.65, blue: 0.7)],
                        center: .center,
                        startRadius: 1,
                        endRadius: 30
                    )
                )

            HStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { _ in
                    Capsule()
                        .fill(Color(red: 0.92, green: 0.55, blue: 0.6))
                        .frame(width: 4, height: 8)
                }
            }
            .offset(y: 8)
        }
    }
}

struct HayBaleView: View {
    var body: some View {
        GeometryReader { geo in
            let W = geo.size.width
            let H = geo.size.height

            ZStack {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.9, blue: 0.5),
                                Color(red: 0.78, green: 0.6, blue: 0.26)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                VStack(spacing: H * 0.2) {
                    ForEach(0..<3, id: \.self) { _ in
                        Rectangle()
                            .fill(Color(red: 0.5, green: 0.38, blue: 0.18).opacity(0.45))
                            .frame(height: 0.8)
                            .padding(.horizontal, W * 0.12)
                    }
                }

                Capsule()
                    .stroke(Color(red: 0.42, green: 0.32, blue: 0.16).opacity(0.65), lineWidth: 0.8)
            }
            .shadow(color: .black.opacity(0.25), radius: 3, x: 1, y: 2)
        }
    }
}

struct Ear: View {
    let darkColor: Color

    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [darkColor, darkColor.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.78, blue: 0.8),
                            Color(red: 0.85, green: 0.55, blue: 0.58)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .scaleEffect(x: 0.55, y: 0.72)
                .offset(y: 1)
        }
    }
}

struct CowHead: View {
    let grazing: Bool
    let appearance: CowAppearance

    var body: some View {
        GeometryReader { geo in
            let W = geo.size.width
            let H = geo.size.height
            let HW = W * 0.62
            let HH = H * 0.7

            ZStack {
                // Far ear (behind head, peeking up from back-top)
                Ear(darkColor: appearance.darkColor)
                    .frame(width: W * 0.16, height: H * 0.2)
                    .rotationEffect(.degrees(-40))
                    .offset(x: -W * 0.16, y: -H * 0.42)

                if appearance.hasHorns {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.95, green: 0.88, blue: 0.78), Color(red: 0.7, green: 0.6, blue: 0.45)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: W * 0.05, height: H * 0.13)
                        .rotationEffect(.degrees(-25))
                        .offset(x: -W * 0.08, y: -H * 0.36)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.95, green: 0.88, blue: 0.78), Color(red: 0.7, green: 0.6, blue: 0.45)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: W * 0.05, height: H * 0.13)
                        .rotationEffect(.degrees(20))
                        .offset(x: W * 0.05, y: -H * 0.38)
                }

                // Head (with optional dark patch) — ellipse for a softer, more cow-like silhouette
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color(white: 0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    if let headSpot = appearance.headSpot {
                        Spot(phase: headSpot.phase)
                            .fill(appearance.darkColor)
                            .frame(width: HW * headSpot.size.width, height: HH * headSpot.size.height)
                            .rotationEffect(.degrees(headSpot.rotation))
                            .offset(
                                x: HW * (headSpot.center.x - 0.5),
                                y: HH * (headSpot.center.y - 0.5)
                            )
                    }
                }
                .frame(width: HW, height: HH)
                .mask(
                    Ellipse().frame(width: HW, height: HH)
                )
                .overlay(
                    Ellipse()
                        .stroke(Color(white: 0.55).opacity(0.3), lineWidth: 0.6)
                        .frame(width: HW, height: HH)
                )
                .shadow(color: .black.opacity(0.15), radius: 3, x: 1, y: 2)

                // Snout
                ZStack {
                    Ellipse()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.85, blue: 0.86),
                                    Color(red: 0.93, green: 0.7, blue: 0.74)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            Ellipse().stroke(Color(white: 0.5).opacity(0.25), lineWidth: 0.6)
                        )

                    HStack(spacing: 8) {
                        Ellipse()
                            .fill(Color(white: 0.18))
                            .frame(width: 7, height: 11)
                            .rotationEffect(.degrees(-10))
                        Ellipse()
                            .fill(Color(white: 0.18))
                            .frame(width: 7, height: 11)
                            .rotationEffect(.degrees(10))
                    }
                    .offset(y: -4)

                    Path { p in
                        p.move(to: CGPoint(x: 0, y: 0))
                        p.addQuadCurve(to: CGPoint(x: 18, y: 0), control: CGPoint(x: 9, y: 7))
                    }
                    .stroke(Color(white: 0.3), lineWidth: 1.5)
                    .frame(width: 18, height: 7)
                    .offset(y: 12)
                }
                .frame(width: W * 0.42, height: H * 0.34)
                .offset(x: W * 0.16, y: H * 0.18)

                // Eyes (two)
                CowEye()
                    .frame(width: W * 0.075, height: H * 0.09)
                    .offset(x: -W * 0.06, y: -H * 0.05)

                CowEye()
                    .frame(width: W * 0.075, height: H * 0.09)
                    .offset(x: W * 0.04, y: -H * 0.05)

                // Near ear (in front of head, peeking up from front-top)
                Ear(darkColor: appearance.darkColor)
                    .frame(width: W * 0.18, height: H * 0.22)
                    .rotationEffect(.degrees(40))
                    .offset(x: W * 0.13, y: -H * 0.42)
            }
        }
    }
}

struct CowEye: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                Ellipse()
                    .fill(Color.white)
                    .overlay(
                        Ellipse().stroke(Color(white: 0.4).opacity(0.5), lineWidth: 0.6)
                    )

                Ellipse()
                    .fill(Color(white: 0.05))
                    .frame(width: w * 0.55, height: h * 0.72)

                Circle()
                    .fill(Color.white)
                    .frame(width: w * 0.22, height: w * 0.22)
                    .offset(x: w * 0.1, y: -h * 0.13)
            }
        }
    }
}

// MARK: - Pasture Hosting View

struct CowView: View {
    @ObservedObject var model: PastureModel
    let baseCowWidth: CGFloat
    let baseCowHeight: CGFloat

    private var cowWidth: CGFloat { baseCowWidth * model.appearance.sizeMultiplier }
    private var cowHeight: CGFloat { baseCowHeight * model.appearance.sizeMultiplier }

    var body: some View {
        CowSprite(
            state: model.state,
            legPhase: model.legPhase,
            facing: model.facing,
            bodyBob: model.bodyBob,
            appearance: model.appearance
        )
        .frame(width: cowWidth, height: cowHeight)
        .scaleEffect(model.scale, anchor: .bottom)
        .position(x: model.x, y: model.y)
    }
}

struct PastureView: View {
    let screenFrame: CGRect
    @ObservedObject var herd: Herd

    private var screenSize: CGSize { screenFrame.size }
    private var baseCowHeight: CGFloat { screenSize.height * 0.13 }
    private var baseCowWidth: CGFloat { baseCowHeight * 1.7 }
    private var hayWidth: CGFloat { baseCowHeight * 0.55 }
    private var hayHeight: CGFloat { baseCowHeight * 0.32 }

    var body: some View {
        ZStack {
            // Hay bales — drawn behind cows.
            ForEach(herd.hayBales) { hay in
                HayBaleView()
                    .frame(width: hayWidth, height: hayHeight)
                    .position(hay.position)
            }

            // Cows, sorted by y so closer ones render in front.
            ForEach(herd.cows.sorted(by: { $0.y < $1.y })) { cow in
                CowView(model: cow, baseCowWidth: baseCowWidth, baseCowHeight: baseCowHeight)
            }
        }
        .frame(width: screenSize.width, height: screenSize.height)
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture(count: 1, coordinateSpace: .local) { location in
            herd.dropHay(at: location)
        }
        .onAppear {
            herd.configure(
                bounds: screenSize,
                baseCowSize: CGSize(width: baseCowWidth, height: baseCowHeight)
            )
        }
        .onReceive(Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()) { _ in
            herd.tick(mouseLocation: mouseInView())
        }
    }

    /// Current cursor position in this view's local (top-left origin) coords, or nil if cursor is on another screen.
    private func mouseInView() -> CGPoint? {
        let global = NSEvent.mouseLocation
        guard screenFrame.contains(global) else { return nil }
        return CGPoint(
            x: global.x - screenFrame.origin.x,
            y: screenFrame.height - (global.y - screenFrame.origin.y)
        )
    }
}

// MARK: - App Setup

final class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var windows: [NSWindow] = []
    var herds: [Herd] = []
    let cowCount: Int

    init(cowCount: Int) {
        self.cowCount = cowCount
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "🐄"
        let menu = NSMenu()
        menu.addItem(withTitle: "Avsluta korna", action: #selector(quit), keyEquivalent: "q")
        statusItem.menu = menu

        for screen in NSScreen.screens {
            let frame = screen.frame
            let herd = Herd(count: cowCount)
            herds.append(herd)

            let window = NSWindow(
                contentRect: frame,
                styleMask: .borderless,
                backing: .buffered,
                defer: false
            )
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false
            // Capture clicks: empty desktop areas hit our window (we sit just under
            // desktop icons, above the wallpaper). App windows above us are unaffected.
            window.ignoresMouseEvents = false
            window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) - 1)
            window.collectionBehavior = [
                .canJoinAllSpaces,
                .stationary,
                .ignoresCycle,
                .fullScreenAuxiliary
            ]

            let view = PastureView(screenFrame: frame, herd: herd)
            let hosting = NSHostingView(rootView: view)
            hosting.frame = NSRect(origin: .zero, size: frame.size)
            window.contentView = hosting
            window.setFrame(frame, display: true)
            window.orderFrontRegardless()

            windows.append(window)
        }
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}

// First positional argument = cow count. Default 4. Clamped to [1, 30].
let cowCount: Int = {
    if CommandLine.arguments.count > 1, let n = Int(CommandLine.arguments[1]) {
        return max(1, min(30, n))
    }
    return 4
}()

let delegate = AppDelegate(cowCount: cowCount)
NSApplication.shared.delegate = delegate
NSApplication.shared.setActivationPolicy(.accessory)
NSApplication.shared.run()
