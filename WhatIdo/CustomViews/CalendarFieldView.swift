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
            Rectangle()
                .stroke(Color.gray, lineWidth: 1)
                .frame(height: 50)
              //  .foregroundColor(Color.fieldbg)
                .clipShape(RoundedRectangle(cornerRadius: 10)) // Apply rounded corners
                .overlay(
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                        HStack {
                            if datePickerPosition == .start {
                                // MARK: - Calendar Icon
                                Image(systemName: "calendar")
                                    .resizable()
                                    .frame(width: 13, height: 14)
                                    .padding(.trailing, 10)
                                    .offset(x: 20)
                            }
                            TextField(text: $fieldInputText) {
                                Text(placeHolder)
                                    .font(.customFont(name: .regular, size: .x16))
                            }.disabled(true)
                                .font(.customFont(name: .medium, size: .x16))
                                .frame(maxHeight: .infinity)
                                .keyboardType(.emailAddress)
                                .padding(.leading, 10)

                            //.padding(.trailing, 10)
                            if datePickerPosition == .end {
                                // MARK: - Calendar Icon
                                Image("calendar")
                                    .resizable()
                                    .frame(width: 13, height: 14)
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
            DatePicker(selection: $selectedDate, in: Date()...month, displayedComponents: .date) {}
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
