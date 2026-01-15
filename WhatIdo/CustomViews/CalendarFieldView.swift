//
//  CalendarFieldView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 30/04/2025.
//


import SwiftUI

enum DateRange {
    case future
    case past
}
enum DateAlignment {
    case start
    case end
}

struct CalendarFieldView: View {
    // MARK: - Properties
    @Binding var fieldInputText: String
    var fieldInputDate: Date? = nil //If there's already date from server
    var placeHolder: String
    var datePickerPosition: DateAlignment
    var datePickerRange: DateRange
    var month: Date

    // MARK: Local Variables
    @State var selectedDate: Date = Date()
    @State var calendarId: UUID = UUID()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
                .frame(height: 50)
                .overlay(
                    ZStack {
                        HStack {
                            if datePickerPosition == .start {
                                // MARK: - Calendar Icon
                                Image(systemName: "calendar")
                                    .resizable()
                                    .foregroundStyle(Color.appPrimaryColor)
                                    .frame(width: 16, height: 16)
                                    .padding(.trailing, 10)
                                    .offset(x: 20)
                            }
                            TextField(text: $fieldInputText) {
                                Text(placeHolder)
                                    .font(.customFont(name: .medium, size: .x16))
                                    .foregroundColor(fieldInputText.isEmpty ? .white.opacity(0.3) : .white)
                                    .padding(.leading, 5)
                            }.disabled(true)
                                .foregroundColor(fieldInputText.isEmpty ? .white.opacity(0.3) : .white)
                                .font(.customFont(name: .medium, size: .x16))
                                .frame(maxHeight: .infinity)
                                .keyboardType(.emailAddress)
                                .padding(.leading, 10)

                            //.padding(.trailing, 10)
                            if datePickerPosition == .end {
                                // MARK: - Calendar Icon
                                Image("calendar")
                                    .resizable()
                                    .foregroundStyle(Color.appPrimaryColor)
                                    .frame(width: 16, height: 16)
                                    .padding(.trailing, 10)
                                    .offset(x: -10)
                            }
                            
                        }.onChange(of: selectedDate) {newDate in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.fieldInputText = newDate.toDateReturnString()
                                self.calendarId = UUID()
                            }
                        }.contentShape(Rectangle())
                    }
                ).zIndex(1)
               
        }.overlay {
            CalendarIcon(calendarId: $calendarId, selectedDate: $selectedDate, datePickerRange: datePickerRange, month: month)
        }.onChange(of: fieldInputText, perform: { newValue in
            self.selectedDate = newValue.toDateFormat() ?? Date()
        })
        .onAppear(perform: {
            if let date = fieldInputDate {
                self.selectedDate = date
            }
            if fieldInputText == "" {
                self.fieldInputText = "Today"
            }
        })
    }
    
}

#Preview {
    CalendarFieldView(fieldInputText: .constant(""), placeHolder: "mm/dd/yyyy", datePickerPosition: .start, datePickerRange: .future, month: Date())
}

fileprivate struct CalendarIcon: View {
    @Binding var calendarId: UUID
    @Binding var selectedDate: Date
    var datePickerRange: DateRange
    var month: Date

    init(calendarId: Binding<UUID>, selectedDate: Binding<Date>, datePickerRange: DateRange, month: Date) {
        self._calendarId = calendarId
        self._selectedDate = selectedDate
        self.datePickerRange = datePickerRange
        self.month = month
    }
    
    var body: some View {
        switch datePickerRange {
        case .future:
            DatePicker(selection: $selectedDate, in: Date()..., displayedComponents: .date) {}
                .tint(Color.black)
                .labelsHidden()
                .contentShape(Rectangle())
                .opacity(0.011)
                .id(calendarId)  
                .onTapGesture(count: 99, perform: {
                    // overrides tap gesture to fix ios 17.1 bug
                })
        case .past:
            DatePicker(selection: $selectedDate, in: month...(month.getMonthName() == Date().getMonthName() ? Date() : month.lastDateOfMonth() ?? Date()), displayedComponents: .date) {}
                .tint(Color.black)
                .labelsHidden()
                .contentShape(Rectangle())
                .opacity(0.011)
                .id(calendarId)  
                .onTapGesture(count: 99, perform: {
                    // overrides tap gesture to fix ios 17.1 bug
                })
        }
    }

//    {
//        if let firstDateOfMonth = Date().getFirstDateOfMonth() {
//            switch datePickerRange {
//            case .future:
//                DatePicker(selection: $selectedDate, in: Date()...firstDateOfMonth, displayedComponents: .date) {}
//                    .tint(Color.black)
//                    .labelsHidden()
//                    .contentShape(Rectangle())
//                    .opacity(0.011)
//                    .id(calendarId)
//                    .onTapGesture(count: 99, perform: {
//                        // overrides tap gesture to fix ios 17.1 bug
//                    })
//            case .past:
//                DatePicker(selection: $selectedDate, in: firstDateOfMonth...Date(), displayedComponents: .date) {}
//                    .tint(Color.black)
//                    .labelsHidden()
//                    .contentShape(Rectangle())
//                    .opacity(0.011)
//                    .id(calendarId)
//                    .onTapGesture(count: 99, perform: {
//                        // overrides tap gesture to fix ios 17.1 bug
//                    })
//            }
//        }
//    }
}
