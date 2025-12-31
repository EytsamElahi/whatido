//
//  AuthSocialProvider.swift
//  WhatIdo
//
//  Created by eytsam elahi on 31/12/2025.
//


public enum AuthSocialProvider: String, CaseIterable, Identifiable, Equatable{
    case google
    case apple

    public var id: String { rawValue }

    public var providerID: String {
        switch self {
        case .google:        return "google.com"
        case .apple:         return "apple.com"
        }
    }

    public var displayName: String {
        switch self {
        case .google:        return "Google"
        case .apple:         return "Apple"
        }
    }

    // Short, user-facing names (EN/EL)
    var displayNameEN: String {
        switch self {
        case .google:        return "Google"
        case .apple:         return "Apple"
        }
    }

    // SF Symbol fallbacks (use brand assets in production)
    var sfSymbol: String {
        switch self {
        case .google:        return "g.circle"
        case .apple:         return "apple.logo"
        }
    }
}
