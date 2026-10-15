import Foundation

public struct TokenUsage: Sendable, Hashable, Codable {
    public var promptTokens: Int
    public var completionTokens: Int
    public var cachedTokens: Int
    public var totalTokens: Int
    public var maxContextTokens: Int
    public var requestsThisMinute: Int
    public var requestsToday: Int
    public var maxRPM: Int
    public var maxRPD: Int

    public init(
        promptTokens: Int = 18450,
        completionTokens: Int = 3280,
        cachedTokens: Int = 12000,
        totalTokens: Int = 21730,
        maxContextTokens: Int = 1_000_000,
        requestsThisMinute: Int = 4,
        requestsToday: Int = 142,
        maxRPM: Int = 15,
        maxRPD: Int = 1500
    ) {
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
        self.cachedTokens = cachedTokens
        self.totalTokens = totalTokens
        self.maxContextTokens = maxContextTokens
        self.requestsThisMinute = requestsThisMinute
        self.requestsToday = requestsToday
        self.maxRPM = maxRPM
        self.maxRPD = maxRPD
    }

    public var contextUsageFraction: Double {
        guard maxContextTokens > 0 else { return 0.0 }
        return min(1.0, Double(totalTokens) / Double(maxContextTokens))
    }

    public var contextUsagePercentageString: String {
        let percent = contextUsageFraction * 100
        return String(format: "%.1f%%", percent)
    }

    public var savedCostDollars: Double {
        // Estimated commercial cost: $0.00125 per 1K prompt tokens + $0.005 per 1K completion tokens
        let inputCost = (Double(promptTokens) / 1000.0) * 0.00125
        let outputCost = (Double(completionTokens) / 1000.0) * 0.005
        return inputCost + outputCost
    }

    public var savedCostFormatted: String {
        return String(format: "$%.2f", savedCostDollars)
    }

    public var remainingRPM: Int {
        max(0, maxRPM - requestsThisMinute)
    }

    public var remainingRPD: Int {
        max(0, maxRPD - requestsToday)
    }

    public mutating func addTokens(prompt: Int, completion: Int, cached: Int = 0) {
        promptTokens += prompt
        completionTokens += completion
        cachedTokens += cached
        totalTokens = promptTokens + completionTokens
        requestsThisMinute += 1
        requestsToday += 1
    }
}
