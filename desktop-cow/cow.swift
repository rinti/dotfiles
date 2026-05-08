import SwiftUI
import AppKit

// MARK: - Pet images

/// Loaded once; tries CWD first (run.sh cd's into the source dir), then the
/// executable's own directory.
private func loadPetImage(_ filename: String) -> NSImage? {
    if let img = NSImage(contentsOfFile: filename) { return img }
    let exeDir = URL(fileURLWithPath: CommandLine.arguments[0])
        .deletingLastPathComponent().path
    return NSImage(contentsOfFile: exeDir + "/" + filename)
}

let pelleImage: NSImage? = loadPetImage("pelle.png")
let socksImage: NSImage? = loadPetImage("socks.png")

// MARK: - Cow Facts

let cowFacts: [String] = [
    "Kor har bästisar och blir stressade om de skiljs åt.",
    "En ko kan producera ungefär 200 000 glas mjölk under sin livstid.",
    "Kor ser nästan 360° runt om sig.",
    "Kor känner igen över 100 andra individer i flocken.",
    "Kor sover bara cirka 4 timmar per dygn.",
    "En vuxen ko dricker upp till 180 liter vatten om dagen.",
    "Kor har fyra magar — egentligen en mage med fyra delar.",
    "Kor idisslar i upp till åtta timmar varje dag.",
    "Kor luktar saker på flera kilometers avstånd.",
    "Det finns över en miljard kor i världen.",
    "Kor har bra minne och kommer ihåg ansikten i flera år.",
    "En ko kan väga lika mycket som en liten bil.",
    "Varje ko har sin egen unika 'röst' när hon råmar.",
    "Kor älskar att bli klappade, särskilt på halsen.",
    "Kor blir gladare när de får lyssna på lugn musik.",
    "Kalvar kan gå redan efter någon timme.",
    "Kor föredrar att sova liggande på vänster sida.",
    "En ko har 32 tänder men inga övre framtänder.",
    "Kor kan simma — om de behöver.",
    "Kor blir kompisar med specifika individer i flocken."
]

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
    enum CowState { case walking, grazing, following, headingToHay, eatingHay, sleeping }

    /// Mouse must come within this distance (px) before the cow starts following.
    static let followStart: CGFloat = 80
    /// Once following, the cow stops following only after the mouse is this far away.
    static let followStop: CGFloat = 220
    /// Seconds spent eating each hay bale.
    static let eatingDuration: TimeInterval = 5.0
    /// Probability that grazing transitions to sleeping rather than walking.
    static let sleepChance: Double = 0.25
    /// How long a fact stays visible.
    static let factDuration: TimeInterval = 9.0

    let id = UUID()
    let appearance: CowAppearance
    weak var herd: Herd?

    @Published var x: CGFloat = 0
    @Published var y: CGFloat = 0
    @Published var facing: CGFloat = 1
    @Published var state: CowState = .walking
    @Published var legPhase: Double = 0
    @Published var bodyBob: Double = 0
    @Published var factText: String? = nil

    var hayTargetId: UUID?
    var hayTargetPos: CGPoint?
    var hayApproachFacing: CGFloat = 1

    private var targetX: CGFloat = 0
    private var targetY: CGFloat = 0
    private var bounds: CGSize = .zero
    private var cowSize: CGSize = .zero
    private var grazingUntil: Date = .distantPast
    private var eatingUntil: Date = .distantPast
    private var sleepingUntil: Date = .distantPast
    private var factUntil: Date = .distantPast
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
        hayApproachFacing = (position.x >= x) ? 1 : -1
        state = .headingToHay
    }

    func showFact(_ text: String) {
        factText = text
        factUntil = Date().addingTimeInterval(Self.factDuration)
    }

    func tick(mouseLocation: CGPoint?) {
        let s = scale

        // Clear expired fact bubble regardless of state.
        if factText != nil, Date() > factUntil {
            factText = nil
        }

        // Hay assignment overrides everything else (and wakes a sleeping cow).
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

        // Mouse proximity drives the .following state. Sleeping cows wake into following.
        if let mouse = mouseLocation {
            let mdist = hypot(mouse.x - x, mouse.y - y)
            switch state {
            case .walking, .grazing, .sleeping:
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
        case .sleeping: handleSleeping()
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
            if Double.random(in: 0...1) < Self.sleepChance {
                state = .sleeping
                sleepingUntil = Date().addingTimeInterval(.random(in: 20...45))
                return
            }
            pickNewTarget()
            state = .walking
            return
        }
        bodyBob = sin(Date().timeIntervalSinceReferenceDate * 2.2) * 0.4
    }

    private func handleSleeping() {
        if Date() > sleepingUntil {
            state = .walking
            pickNewTarget()
            return
        }
        // Slow breathing.
        bodyBob = sin(Date().timeIntervalSinceReferenceDate * 0.9) * 0.25
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

        let stop = hayStopPosition(for: hayPos)
        let dx = stop.x - x
        let dy = stop.y - y
        let dist = sqrt(dx * dx + dy * dy)

        if dist < 4 {
            state = .eatingHay
            eatingUntil = Date().addingTimeInterval(Self.eatingDuration)
            facing = hayApproachFacing
            return
        }

        let speed: CGFloat = 1.6 * s   // hungry — slightly faster
        x += (dx / dist) * speed
        y += (dy / dist) * speed
        facing = hayApproachFacing
        legPhase += 0.2 * s
        bodyBob = sin(legPhase) * 0.6
    }

    /// Where the cow should stand to nibble the hay: just to its side, head down.
    private func hayStopPosition(for hayPos: CGPoint) -> CGPoint {
        // Cow's feet should be roughly aligned with the hay bale's bottom.
        // hayHeight ≈ baseCowHeight * 0.32 ⇒ cow.y = hay.y + (hayH - cowH)/2 ≈ hay.y - 0.34*cowH
        let rawStopY = hayPos.y - cowSize.height * 0.34
        let stopY = max(yMin, min(yMax, rawStopY))

        // Approximate perspective scale at the stop position.
        let t = (stopY - yMin) / max(0.0001, yMax - yMin)
        let stopScale: CGFloat = 0.5 + 0.5 * max(0, min(1, t))

        // Stop with the snout reaching the bale's near edge so the body stays mostly off the bale.
        let halfHay = cowSize.height * 0.275                 // hayWidth/2 ≈ baseCowH * 0.55 / 2
        let snoutOffset = cowSize.width * 0.34 * stopScale   // sprite snout x ≈ W*0.84 from left
        let stopX = hayPos.x - hayApproachFacing * (halfHay + snoutOffset)
        return CGPoint(x: stopX, y: stopY)
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
final class Companion: ObservableObject, Identifiable {
    /// Switch to a new cow at this cadence.
    static let switchInterval: TimeInterval = 60

    /// Minimum gap (px) between the companion's near edge and the cow's visual edge.
    static let gap: CGFloat = 10

    let id = UUID()
    let name: String
    let image: NSImage
    /// `-1` = trail behind the cow (opposite its facing). `+1` = lead in front of it (same as facing).
    let trailSign: CGFloat
    let aspectRatio: CGFloat

    @Published var x: CGFloat = 0
    @Published var y: CGFloat = 0
    @Published var facing: CGFloat = 1

    var target: PastureModel?
    private var nextSwitchAt: Date = .distantPast
    private var bounds: CGSize = .zero
    private var heightHint: CGFloat = 80
    private var configured = false

    init(name: String, image: NSImage, trailSign: CGFloat = -1) {
        self.name = name
        self.image = image
        self.trailSign = trailSign
        let s = image.size
        self.aspectRatio = s.height > 0 ? s.width / s.height : 1
    }

    var scale: CGFloat {
        let yMin = bounds.height / 3
        let yMax = bounds.height - heightHint * 0.5
        guard yMax > yMin else { return 1 }
        let t = (y - yMin) / (yMax - yMin)
        return 0.5 + 0.5 * max(0, min(1, t))
    }

    func configure(bounds: CGSize, cows: [PastureModel], height: CGFloat) {
        self.bounds = bounds
        self.heightHint = height
        guard !configured, !cows.isEmpty else { return }
        configured = true
        target = cows.randomElement()
        nextSwitchAt = Date().addingTimeInterval(Self.switchInterval)
        if let t = target {
            x = t.x + trailSign * t.facing * trailDistance(for: t)
            y = t.y
        } else {
            x = bounds.width / 2
            y = bounds.height * 0.6
        }
    }

    /// Distance from cow center where the companion should sit so its near edge clears
    /// the cow's by `gap`. heightHint is half the cow's base height, so the visible cow
    /// body spans about 90% of its frame ⇒ cow visual half ≈ 1.55 * heightHint.
    private func trailDistance(for cow: PastureModel) -> CGFloat {
        let cowHalf = heightHint * 1.55 * cow.scale
        let petHalf = aspectRatio * heightHint * 0.5 * scale
        return cowHalf + petHalf + Self.gap
    }

    func tick(cows: [PastureModel]) {
        if Date() > nextSwitchAt && !cows.isEmpty {
            let candidates = cows.filter { $0.id != target?.id }
            target = candidates.randomElement() ?? cows.randomElement()
            nextSwitchAt = Date().addingTimeInterval(Self.switchInterval)
        }
        guard let t = target else { return }
        // trailSign=-1 trails behind cow's facing; +1 leads in front.
        let goalX = t.x + trailSign * t.facing * trailDistance(for: t)
        let goalY = t.y
        let dx = goalX - x
        let dy = goalY - y
        let dist = sqrt(dx * dx + dy * dy)
        let speed: CGFloat = 1.6 * scale
        if dist > 3 {
            x += (dx / dist) * speed
            y += (dy / dist) * speed
            facing = dx >= 0 ? 1 : -1
        }
    }
}

@MainActor
final class Herd: ObservableObject {
    let cows: [PastureModel]
    @Published var hayBales: [HayBale] = []
    let companions: [Companion]
    private var bounds: CGSize = .zero

    private var nextRandomHayAt: Date = Date().addingTimeInterval(.random(in: 90...150))
    private var nextFactAt: Date = Date().addingTimeInterval(.random(in: 240...360))

    init(count: Int) {
        cows = (0..<count).map { _ in PastureModel() }
        var pets: [Companion] = []
        if let img = pelleImage {
            pets.append(Companion(name: "Pelle", image: img, trailSign: -1))
        }
        if let img = socksImage {
            pets.append(Companion(name: "Socks", image: img, trailSign: 1))
        }
        companions = pets
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
        for pet in companions {
            pet.configure(bounds: bounds, cows: cows, height: baseCowSize.height * 0.50)
        }
    }

    func tick(mouseLocation: CGPoint?) {
        let now = Date()

        if now > nextRandomHayAt {
            dropRandomHay()
            nextRandomHayAt = now.addingTimeInterval(.random(in: 110...130))
        }

        if now > nextFactAt {
            triggerRandomFact()
            nextFactAt = now.addingTimeInterval(.random(in: 270...330))
        }

        for cow in cows {
            cow.tick(mouseLocation: mouseLocation)
        }
        for pet in companions {
            pet.tick(cows: cows)
        }
        // Force PastureView to re-evaluate so the y-sorted ForEach reorders items.
        objectWillChange.send()
    }

    private func dropRandomHay() {
        guard !cows.isEmpty, bounds.width > 0 else { return }
        let yMinHay = bounds.height / 3
        let yMaxHay = bounds.height - 30
        let xMargin: CGFloat = 30
        let pt = CGPoint(
            x: CGFloat.random(in: xMargin...(bounds.width - xMargin)),
            y: CGFloat.random(in: yMinHay...yMaxHay)
        )
        dropHay(at: pt)
    }

    private func triggerRandomFact() {
        let candidates = cows.filter { $0.state != .sleeping && $0.factText == nil }
        guard let cow = candidates.randomElement(),
              let fact = cowFacts.randomElement() else { return }
        cow.showFact(fact)
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
            let sleeping = state == .sleeping
            let bodyOffset: CGFloat = sleeping ? H * 0.20 : 0

            ZStack {
                // Tail
                CowTail()
                    .stroke(appearance.darkColor, style: StrokeStyle(lineWidth: max(2, H * 0.022), lineCap: .round))
                    .frame(width: W * 0.16, height: H * 0.32)
                    .position(x: W * 0.13, y: H * 0.42 + bodyBob + bodyOffset)

                Ellipse()
                    .fill(appearance.darkColor)
                    .frame(width: H * 0.09, height: H * 0.07)
                    .rotationEffect(.degrees(35))
                    .position(x: W * 0.06, y: H * 0.62 + bodyBob + bodyOffset)

                if !sleeping {
                    // Back legs (behind body)
                    Leg(phase: legPhase + .pi, isWalking: isMoving)
                        .frame(width: W * 0.05, height: H * 0.42)
                        .position(x: W * 0.27, y: H * 0.78)

                    Leg(phase: legPhase, isWalking: isMoving)
                        .frame(width: W * 0.05, height: H * 0.42)
                        .position(x: W * 0.55, y: H * 0.78)
                }

                // Body
                CowBody(appearance: appearance)
                    .frame(width: W * 0.7, height: H * 0.5)
                    .position(x: W * 0.42, y: H * 0.42 + bodyBob + bodyOffset)

                // Udder — tucked away when lying down
                if !sleeping {
                    Udder()
                        .frame(width: W * 0.13, height: H * 0.14)
                        .position(x: W * 0.4, y: H * 0.7 + bodyBob * 0.5)
                }

                if !sleeping {
                    // Front legs (in front of body)
                    Leg(phase: legPhase + .pi + 0.6, isWalking: isMoving)
                        .frame(width: W * 0.05, height: H * 0.42)
                        .position(x: W * 0.32, y: H * 0.78)

                    Leg(phase: legPhase + 0.6, isWalking: isMoving)
                        .frame(width: W * 0.05, height: H * 0.42)
                        .position(x: W * 0.6, y: H * 0.78)
                }

                // Head — tucked low and closer to body when sleeping
                CowHead(grazing: headDown, closed: sleeping, appearance: appearance)
                    .frame(width: W * 0.36, height: H * 0.45)
                    .position(
                        x: sleeping ? W * 0.66 : W * 0.78,
                        y: sleeping ? H * 0.62 + bodyBob : (headDown ? H * 0.8 : H * 0.32 + bodyBob)
                    )
                    .animation(.easeInOut(duration: 0.45), value: headDown)
                    .animation(.easeInOut(duration: 0.6), value: sleeping)
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

struct StrawStroke: Identifiable {
    let id = UUID()
    var from: CGPoint   // normalized 0..1
    var to: CGPoint
    var color: Color
    var width: CGFloat
}

struct HayWisp: Identifiable {
    let id = UUID()
    var fromX: CGFloat   // normalized 0..1 across top edge
    var dx: CGFloat      // pixels outward
    var dy: CGFloat      // pixels outward (negative = up)
    var color: Color
    var width: CGFloat
}

struct HayBaleView: View {
    @State private var strokes: [StrawStroke] = HayBaleView.makeStrokes()
    @State private var wisps: [HayWisp] = HayBaleView.makeWisps()

    var body: some View {
        GeometryReader { geo in
            let W = geo.size.width
            let H = geo.size.height
            let r = H * 0.18

            ZStack {
                // Wisps poking up from inside the top edge — drawn first so the bale covers their roots.
                ForEach(wisps) { wisp in
                    Path { p in
                        let x0 = wisp.fromX * W
                        p.move(to: CGPoint(x: x0, y: H * 0.10))
                        p.addLine(to: CGPoint(x: x0 + wisp.dx, y: wisp.dy))
                    }
                    .stroke(wisp.color, style: StrokeStyle(lineWidth: wisp.width, lineCap: .round))
                }

                // Body + straw fiber texture, clipped to the rounded rect.
                ZStack {
                    RoundedRectangle(cornerRadius: r)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.00, green: 0.88, blue: 0.50),
                                    Color(red: 0.88, green: 0.68, blue: 0.28),
                                    Color(red: 0.62, green: 0.42, blue: 0.16)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    ForEach(strokes) { stroke in
                        Path { p in
                            p.move(to: CGPoint(x: stroke.from.x * W, y: stroke.from.y * H))
                            p.addLine(to: CGPoint(x: stroke.to.x * W, y: stroke.to.y * H))
                        }
                        .stroke(stroke.color, style: StrokeStyle(lineWidth: stroke.width, lineCap: .round))
                    }

                    // Top sheen
                    RoundedRectangle(cornerRadius: r)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.55), Color.white.opacity(0)],
                                startPoint: .top,
                                endPoint: .center
                            ),
                            lineWidth: 1.2
                        )
                }
                .clipShape(RoundedRectangle(cornerRadius: r))

                // Twine — two vertical strings wrapping the bale.
                ForEach([-0.24, 0.24], id: \.self) { off in
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.97, green: 0.88, blue: 0.60),
                                    Color(red: 0.78, green: 0.66, blue: 0.40)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(1.6, W * 0.025), height: H * 1.04)
                        .overlay(
                            Capsule()
                                .stroke(Color(red: 0.45, green: 0.34, blue: 0.16).opacity(0.5), lineWidth: 0.4)
                        )
                        .offset(x: W * CGFloat(off))
                }

                // Outer outline
                RoundedRectangle(cornerRadius: r)
                    .stroke(Color(red: 0.30, green: 0.20, blue: 0.08).opacity(0.5), lineWidth: 0.9)
            }
            .shadow(color: .black.opacity(0.3), radius: 3, x: 1, y: 2)
        }
    }

    private static func makeStrokes() -> [StrawStroke] {
        (0..<32).map { _ in
            let cx = CGFloat.random(in: 0.05...0.95)
            let cy = CGFloat.random(in: 0.08...0.92)
            let len = CGFloat.random(in: 0.05...0.20)
            let angle = Double.random(in: -0.55...0.55)   // mostly horizontal
            let dx = CGFloat(cos(angle)) * len * 0.5
            let dy = CGFloat(sin(angle)) * len * 0.5
            let darken = Double.random(in: 0.0...0.55)
            return StrawStroke(
                from: CGPoint(x: cx - dx, y: cy - dy),
                to: CGPoint(x: cx + dx, y: cy + dy),
                color: Color(
                    red: 0.55 - darken * 0.30,
                    green: 0.42 - darken * 0.25,
                    blue: 0.20 - darken * 0.10
                ).opacity(Double.random(in: 0.45...0.9)),
                width: CGFloat.random(in: 0.5...1.3)
            )
        }
    }

    private static func makeWisps() -> [HayWisp] {
        (0..<8).map { _ in
            let fromX = CGFloat.random(in: 0.10...0.90)
            let len = CGFloat.random(in: 5...11)
            let angle = -Double.pi / 2 + Double.random(in: -0.6...0.6)  // mostly upward
            let dx = CGFloat(cos(angle)) * len
            let dy = CGFloat(sin(angle)) * len
            let darken = Double.random(in: 0.0...0.35)
            return HayWisp(
                fromX: fromX,
                dx: dx,
                dy: dy,
                color: Color(
                    red: 0.85 - darken * 0.20,
                    green: 0.70 - darken * 0.15,
                    blue: 0.35 - darken * 0.10
                ).opacity(0.85),
                width: CGFloat.random(in: 0.8...1.5)
            )
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
    let closed: Bool
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
                CowEye(closed: closed)
                    .frame(width: W * 0.075, height: H * 0.09)
                    .offset(x: -W * 0.06, y: -H * 0.05)

                CowEye(closed: closed)
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
    var closed: Bool = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            if closed {
                Path { p in
                    p.move(to: CGPoint(x: w * 0.08, y: h * 0.5))
                    p.addQuadCurve(
                        to: CGPoint(x: w * 0.92, y: h * 0.5),
                        control: CGPoint(x: w * 0.5, y: h * 0.92)
                    )
                }
                .stroke(Color(white: 0.15), style: StrokeStyle(lineWidth: max(1, h * 0.14), lineCap: .round))
            } else {
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
}

// MARK: - Overlays

struct SleepZs: View {
    var body: some View {
        TimelineView(.animation) { context in
            let now = context.date.timeIntervalSinceReferenceDate
            ZStack {
                zChar(size: 10, t: phase(now, delay: 0.0))
                zChar(size: 14, t: phase(now, delay: 0.8))
                zChar(size: 18, t: phase(now, delay: 1.6))
            }
        }
    }

    private func phase(_ now: Double, delay: Double) -> Double {
        let cycle = 2.5
        var v = (now - delay).truncatingRemainder(dividingBy: cycle) / cycle
        if v < 0 { v += 1 }
        return v
    }

    private func zChar(size: CGFloat, t: Double) -> some View {
        // sin(πt) gives 0 → 1 → 0 over the cycle so the Z fades in and out.
        let alpha = sin(.pi * t) * 0.95
        return Text("z")
            .font(.system(size: size, weight: .bold, design: .rounded))
            .foregroundColor(Color.white.opacity(alpha))
            .shadow(color: Color.black.opacity(0.5 * alpha), radius: 1.5)
            .offset(x: CGFloat(t) * 10, y: -CGFloat(t) * 26)
    }
}

struct BubbleTail: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}

struct SpeechBubbleView: View {
    let text: String

    var body: some View {
        VStack(spacing: -1) {
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .frame(maxWidth: 180)
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(Color.white)
                )

            BubbleTail()
                .fill(Color.white)
                .frame(width: 12, height: 7)
        }
        .shadow(color: .black.opacity(0.3), radius: 4, x: 1, y: 2)
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
        ZStack {
            CowSprite(
                state: model.state,
                legPhase: model.legPhase,
                facing: model.facing,
                bodyBob: model.bodyBob,
                appearance: model.appearance
            )
            .frame(width: cowWidth, height: cowHeight)

            // Z's float above sleeping cows (rendered outside the sprite's facing-mirror).
            if model.state == .sleeping {
                SleepZs()
                    .frame(width: 40, height: 36)
                    .offset(y: -cowHeight * 0.42)
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }

            // Speech bubble with a fun cow fact.
            if let text = model.factText {
                SpeechBubbleView(text: text)
                    .offset(y: -cowHeight * 0.65)
                    .allowsHitTesting(false)
                    .transition(.opacity.combined(with: .scale(scale: 0.5, anchor: .bottom)))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: model.factText)
        .animation(.easeInOut(duration: 0.4), value: model.state == .sleeping)
        .scaleEffect(model.scale, anchor: .bottom)
        .position(x: model.x, y: model.y)
    }
}

struct CompanionView: View {
    @ObservedObject var companion: Companion
    let baseCowHeight: CGFloat

    private var petHeight: CGFloat { baseCowHeight * 0.50 }
    private var petWidth: CGFloat { petHeight * companion.aspectRatio }

    var body: some View {
        Image(nsImage: companion.image)
            .resizable()
            .interpolation(.medium)
            .frame(width: petWidth, height: petHeight)
            .scaleEffect(x: companion.facing, y: 1)
            .scaleEffect(companion.scale, anchor: .bottom)
            .shadow(color: .black.opacity(0.25), radius: 3, x: 1, y: 3)
            .position(x: companion.x, y: companion.y)
    }
}

@MainActor
enum PastureItem: Identifiable {
    case cow(PastureModel)
    case hay(HayBale)
    case companion(Companion)

    nonisolated var id: String {
        switch self {
        case .cow(let c): return "cow-\(c.id.uuidString)"
        case .hay(let h): return "hay-\(h.id.uuidString)"
        case .companion(let p): return "pet-\(p.id.uuidString)"
        }
    }

    var sortY: CGFloat {
        switch self {
        case .cow(let c): return c.y
        case .hay(let h): return h.position.y
        case .companion(let p): return p.y
        }
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

    private var sortedItems: [PastureItem] {
        let items = herd.cows.map { PastureItem.cow($0) }
            + herd.hayBales.map { PastureItem.hay($0) }
            + herd.companions.map { PastureItem.companion($0) }
        return items.sorted { $0.sortY < $1.sortY }
    }

    var body: some View {
        ZStack {
            // Cows, hay bales, and companions sorted together by y so closer items render on top.
            ForEach(sortedItems) { item in
                switch item {
                case .cow(let cow):
                    CowView(model: cow, baseCowWidth: baseCowWidth, baseCowHeight: baseCowHeight)
                case .hay(let hay):
                    HayBaleView()
                        .frame(width: hayWidth, height: hayHeight)
                        .position(hay.position)
                case .companion(let pet):
                    CompanionView(companion: pet, baseCowHeight: baseCowHeight)
                }
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
