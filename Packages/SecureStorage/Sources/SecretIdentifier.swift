import Foundation

/// Well-known identifiers for secrets stored in AetherNotes.
/// Using an enum prevents typo-based bugs.
public enum SecretIdentifier: String, Sendable, CaseIterable {
    case openAIAPIKey = "openai-api-key"
    case anthropicAPIKey = "anthropic-api-key"
    case customLLMAPIKey = "custom-llm-api-key"

    /// Human-readable display name (never log the actual value).
    public var displayName: String {
        switch self {
        case .openAIAPIKey: "OpenAI API Key"
        case .anthropicAPIKey: "Anthropic API Key"
        case .customLLMAPIKey: "Custom LLM API Key"
        }
    }
}