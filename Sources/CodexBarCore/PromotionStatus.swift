import Foundation

public enum PromotionStatus: Sendable {
    public struct Result: Sendable {
        public let is2x: Bool
        public let badge: String
    }

    /// Returns `nil` if no promotion applies to this provider at the given time.
    public static func check(provider: UsageProvider, now: Date = Date()) -> Result? {
        switch provider {
        case .claude:
            return checkClaude(now: now)
        case .codex:
            return checkCodex(now: now)
        default:
            return nil
        }
    }

    // MARK: - Claude Spring Break (March 13–27, 2026)

    private static func checkClaude(now: Date) -> Result? {
        let et = TimeZone(identifier: "America/New_York")!
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = et

        // Promo window: March 13, 2026 00:00 ET → March 28, 2026 00:00 ET
        // (March 27 11:59 PM PT ≈ March 28 ~03:00 AM ET)
        let start = cal.date(from: DateComponents(year: 2026, month: 3, day: 13))!
        let end = cal.date(from: DateComponents(year: 2026, month: 3, day: 28))!

        guard now >= start, now < end else { return nil }

        let comps = cal.dateComponents([.weekday, .hour], from: now)
        let weekday = comps.weekday! // 1 = Sun, 7 = Sat
        let hour = comps.hour!

        let isWeekend = weekday == 1 || weekday == 7
        let isPeak = !isWeekend && hour >= 8 && hour < 14

        if isPeak {
            return Result(is2x: false, badge: "Peak")
        }
        return Result(is2x: true, badge: "⚡ 2×")
    }

    // MARK: - Codex 2× (until April 2, 2026)

    private static func checkCodex(now: Date) -> Result? {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/New_York")!
        let end = cal.date(from: DateComponents(year: 2026, month: 4, day: 2))!
        guard now < end else { return nil }
        return Result(is2x: true, badge: "⚡ 2×")
    }
}
