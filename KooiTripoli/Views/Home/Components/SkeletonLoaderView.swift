import SwiftUI

/// Reusable shimmer skeleton loader modifier
/// Mirrors the Kotlin `FoodVisualArt.kt` SkeletonLoader
struct SkeletonLoader: ViewModifier {
    let isLoading: Bool
    @EnvironmentObject private var themeManager: ThemeManager

    func body(content: Content) -> some View {
        if isLoading {
            SkeletonView()
        } else {
            content
        }
    }
}

/// Shimmer skeleton view
struct SkeletonView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var animationOffset: CGFloat = -1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base layer
                RoundedRectangle(cornerRadius: 8)
                    .fill(themeManager.activePalette.skeletonBase)

                // Shimmer highlight
                RoundedRectangle(cornerRadius: 8)
                    .fill(themeManager.activePalette.skeletonHighlight)
                    .mask(
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .white.opacity(0.4),
                                        .white.opacity(0.6),
                                        .white.opacity(0.4),
                                        .clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .rotationEffect(.degrees(30))
                            .offset(x: animationOffset * geometry.size.width * 2)
                    )
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                animationOffset = 1.0
            }
        }
    }
}

/// Skeleton modifier for any view
extension View {
    func skeleton(isLoading: Bool) -> some View {
        modifier(SkeletonLoader(isLoading: isLoading))
    }
}

/// Specific skeleton shapes for common components
struct RestaurantCardSkeleton: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image
            SkeletonView()
                .frame(width: 280, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            // Content
            VStack(alignment: .leading, spacing: 8) {
                SkeletonView()
                    .frame(width: 160, height: 20)

                SkeletonView()
                    .frame(width: 100, height: 14)

                HStack(spacing: 8) {
                    SkeletonView()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())

                    SkeletonView()
                        .frame(width: 60, height: 14)
                }

                HStack(spacing: 12) {
                    SkeletonView()
                        .frame(width: 80, height: 14)

                    SkeletonView()
                        .frame(width: 80, height: 14)

                    SkeletonView()
                        .frame(width: 80, height: 14)
                }

                SkeletonView()
                    .frame(width: 120, height: 6)
            }
            .padding(.horizontal, 4)
        }
        .padding(16)
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: themeManager.activePalette.overlayScrim,
            radius: 6,
            x: 0,
            y: 3
        )
        .frame(width: 280)
    }
}

struct MenuItemSkeleton: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            // Image
            SkeletonView()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            // Content
            VStack(alignment: .leading, spacing: 8) {
                SkeletonView()
                    .frame(width: 140, height: 20)

                SkeletonView()
                    .frame(width: 100, height: 14)

                SkeletonView()
                    .frame(width: 80, height: 14)
            }

            Spacer()
        }
        .padding(16)
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct CategorySkeleton: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        SkeletonView()
            .frame(width: 100, height: 44)
            .clipShape(Capsule())
    }
}

struct HeroCardSkeleton: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    SkeletonView()
                        .frame(width: 180, height: 28)

                    SkeletonView()
                        .frame(width: 140, height: 18)
                }

                Spacer()

                SkeletonView()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }

            SkeletonView()
                .frame(width: 100, height: 36)
                .clipShape(Capsule())
        }
        .padding(20)
        .background(themeManager.activePalette.primary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct FeatureCardSkeleton: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonView()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 4) {
                SkeletonView()
                    .frame(width: 100, height: 18)

                SkeletonView()
                    .frame(width: 80, height: 14)
            }
        }
        .padding(16)
        .frame(width: 160, alignment: .leading)
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct CartItemSkeleton: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            SkeletonView()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 6) {
                SkeletonView()
                    .frame(width: 160, height: 18)

                SkeletonView()
                    .frame(width: 100, height: 14)

                HStack(spacing: 12) {
                    SkeletonView()
                        .frame(width: 60, height: 28)
                        .clipShape(Capsule())

                    SkeletonView()
                        .frame(width: 80, height: 14)
                }
            }

            Spacer()
        }
        .padding(16)
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct GroupCartBarSkeleton: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                SkeletonView()
                    .frame(width: 100, height: 14)

                SkeletonView()
                    .frame(width: 140, height: 18)
            }

            Spacer()

            SkeletonView()
                .frame(width: 120, height: 48)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(themeManager.activePalette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: themeManager.activePalette.overlayScrim,
            radius: 14,
            x: 0,
            y: -4
        )
    }
}