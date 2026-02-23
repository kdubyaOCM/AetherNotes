/// Single source of truth for minimum OS version constants.
/// Mirrors the values in Package.swift and the Xcode project build settings.
/// Use these for runtime feature-gating checks if needed.
///
/// See Docs/STATE.md §Minimum OS versions for the authoritative table.
public enum PlatformTargets {
    /// Minimum supported iOS version.
    public static let iOSMinimum = "17.0"
    /// Minimum supported iPadOS version (same SDK as iOS).
    public static let iPadOSMinimum = "17.0"
    /// Minimum supported macOS version (Sonoma).
    public static let macOSMinimum = "14.0"
    /// Minimum supported watchOS version.
    public static let watchOSMinimum = "10.0"
}
