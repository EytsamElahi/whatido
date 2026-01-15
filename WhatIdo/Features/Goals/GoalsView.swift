//
//  GoalsView.swift
//  WhatIdo
//
//  Created by Cursor AI on 15/01/2026.
//

import SwiftUI

struct GoalsView: View {
  @EnvironmentObject var navigation: NavigationManager
  @StateObject var viewModel: GoalsViewModel

  @State private var notificationsEnabled: Bool = true
  @State private var selectedDateText: String = "This Month"

  private var completedCount: Int {
    viewModel.goals.filter { $0.isCompleted }.count
  }

  private var activeCount: Int {
    viewModel.goals.filter { !$0.isCompleted }.count
  }

  private var completionRate: Double {
    let total = viewModel.goals.count
    guard total > 0 else { return 0 }
    return Double(completedCount) / Double(total)
  }

  var body: some View {
    ZStack {
      Color.appBackground.ignoresSafeArea()

      VStack(spacing: 0) {
        AppHeaderView(
          title: "Goals",
          trailingButtonIcon: "bell.fill",
          backAction: {
            navigation.pop()
          },
          trailingButtonAction: {
            notificationsEnabled.toggle()
          }
        )

        ScrollView(showsIndicators: false) {
          VStack(spacing: 20) {
            streakSection
            calendarSection
            gamificationStatsSection
            notificationsSection
            goalsListSection
          }
          .padding(.horizontal, 20)
          .padding(.bottom, 24)
        }
      }
    }
    .navigationBarHidden(true)
    .onAppear {
      viewModel.fetchGoals()
    }
  }

  // MARK: - Sections

  private var streakSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Streak")
        .font(.customFont(family: .quicksand, name: .bold, size: .x18))
        .foregroundStyle(Color.textPrimary)

      HStack(spacing: 16) {
        ZStack {
          Circle()
            .stroke(Color.white.opacity(0.1), lineWidth: 10)
            .frame(width: 90, height: 90)

          Circle()
            .trim(from: 0, to: CGFloat(min(max(completionRate, 0.15), 1.0)))
            .stroke(
              AngularGradient(
                gradient: Gradient(colors: [Color.appPrimaryColor, Color.appPrimaryColor.opacity(0.4)]),
                center: .center
              ),
              style: StrokeStyle(lineWidth: 10, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))

          VStack(spacing: 4) {
            Text("\(max(completedCount, 1))")
              .font(.customFont(family: .quicksand, name: .bold, size: .x24))
              .foregroundStyle(Color.textPrimary)
            Text("Day\(completedCount == 1 ? "" : "s")")
              .font(.customFont(family: .quicksand, name: .medium, size: .x12))
              .foregroundStyle(Color.textSecondary)
          }
        }

        VStack(alignment: .leading, spacing: 6) {
          Text("Don't break the chain")
            .font(.customFont(family: .quicksand, name: .bold, size: .x16))
            .foregroundStyle(Color.textPrimary)

          Text("Complete at least one goal every day to keep your streak alive.")
            .font(.customFont(family: .inter, name: .regular, size: .x12))
            .foregroundStyle(Color.textSecondary)

          HStack(spacing: 8) {
            Label("\(completedCount) completed", systemImage: "checkmark.seal.fill")
              .font(.customFont(family: .inter, name: .medium, size: .x12))
              .foregroundStyle(Color.appPrimaryColor)

            Text("•")
              .foregroundStyle(Color.textSecondary)

            Text("\(activeCount) active")
              .font(.customFont(family: .inter, name: .medium, size: .x12))
              .foregroundStyle(Color.textSecondary)
          }
        }

        Spacer()
      }
      .padding(16)
      .background(
        RoundedRectangle(cornerRadius: 18)
          .fill(Color.cardBackground)
      )
    }
  }

  private var calendarSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Focus Calendar")
        .font(.customFont(family: .quicksand, name: .bold, size: .x18))
        .foregroundStyle(Color.textPrimary)

      CalendarFieldView(
        fieldInputText: $selectedDateText,
        placeHolder: "Select period",
        datePickerPosition: .start,
        datePickerRange: .future,
        month: Date()
      )
    }
  }

  private var gamificationStatsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Progress")
        .font(.customFont(family: .quicksand, name: .bold, size: .x18))
        .foregroundStyle(Color.textPrimary)

      HStack(spacing: 12) {
        statCard(
          title: "Level",
          value: "1",
          subtitle: "Keep going to level up",
          icon: "star.fill"
        )

        statCard(
          title: "XP",
          value: "\(completedCount * 50)",
          subtitle: "+50 per completed goal",
          icon: "bolt.fill"
        )
      }
    }
  }

  private func statCard(title: String, value: String, subtitle: String, icon: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: icon)
          .font(.system(size: 16))
          .foregroundStyle(Color.appPrimaryColor)
        Text(title)
          .font(.customFont(family: .quicksand, name: .medium, size: .x14))
          .foregroundStyle(Color.textSecondary)
      }

      Text(value)
        .font(.customFont(family: .quicksand, name: .bold, size: .x24))
        .foregroundStyle(Color.textPrimary)

      Text(subtitle)
        .font(.customFont(family: .inter, name: .regular, size: .x12))
        .foregroundStyle(Color.textSecondary)
        .lineLimit(2)
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.cardBackground)
    )
  }

  private var notificationsSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text("Daily nudges")
          .font(.customFont(family: .quicksand, name: .bold, size: .x18))
          .foregroundStyle(Color.textPrimary)
        Spacer()
        Toggle("", isOn: $notificationsEnabled)
          .labelsHidden()
          .tint(Color.appPrimaryColor)
      }

      Text("Get a gentle reminder every evening to reflect and tick off your goals.")
        .font(.customFont(family: .inter, name: .regular, size: .x12))
        .foregroundStyle(Color.textSecondary)
    }
    .padding(14)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.cardBackground)
    )
  }

  private var goalsListSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("Your Goals")
          .font(.customFont(family: .quicksand, name: .bold, size: .x18))
          .foregroundStyle(Color.textPrimary)
        Spacer()
        Text("\(viewModel.goals.count)")
          .font(.customFont(family: .inter, name: .medium, size: .x12))
          .foregroundStyle(Color.textSecondary)
      }

      if viewModel.goals.isEmpty {
        VStack(spacing: 8) {
          Image(systemName: "target")
            .font(.system(size: 32))
            .foregroundStyle(Color.textSecondary.opacity(0.6))
          Text("No goals yet")
            .font(.customFont(family: .quicksand, name: .bold, size: .x16))
            .foregroundStyle(Color.textPrimary)
          Text("Start with one small, clear goal to build momentum.")
            .font(.customFont(family: .inter, name: .regular, size: .x12))
            .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
          RoundedRectangle(cornerRadius: 18)
            .fill(Color.cardBackground)
        )
      } else {
        VStack(spacing: 10) {
          ForEach(viewModel.goals, id: \.self) { goal in
            goalRow(goal)
          }
        }
      }
    }
  }

  private func goalRow(_ goal: Goal) -> some View {
    HStack(alignment: .center, spacing: 12) {
      ZStack {
        Circle()
          .fill(goal.isCompleted ? Color.appPrimaryColor.opacity(0.15) : Color.white.opacity(0.06))
          .frame(width: 32, height: 32)
        Image(systemName: goal.isCompleted ? "checkmark" : "target")
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(goal.isCompleted ? Color.appPrimaryColor : Color.textSecondary)
      }

      VStack(alignment: .leading, spacing: 4) {
        Text(goal.title)
          .font(.customFont(family: .quicksand, name: .semiBold, size: .x16))
          .foregroundStyle(Color.textPrimary)
          .lineLimit(2)

        Text(goal.targetDate.formatted(.dateTime.day().month().year()))
          .font(.customFont(family: .inter, name: .regular, size: .x12))
          .foregroundStyle(Color.textSecondary)
      }

      Spacer()

      let tagText = goal.isCompleted ? "Completed" : "In Progress"
      let tagColor = goal.isCompleted ? Color.appPrimaryColor : Color.white.opacity(0.1)
      let tagTextColor = goal.isCompleted ? Color.black : Color.textSecondary

      Text(tagText)
        .font(.customFont(family: .inter, name: .medium, size: .x10))
        .foregroundStyle(tagTextColor)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(
          Capsule()
            .fill(tagColor)
        )
    }
    .padding(12)
    .background(
      RoundedRectangle(cornerRadius: 14)
        .fill(Color.cardBackground)
    )
  }
}

#Preview {
    GoalsView(viewModel: GoalsViewModel(goalsService: GoalsService()))
}
