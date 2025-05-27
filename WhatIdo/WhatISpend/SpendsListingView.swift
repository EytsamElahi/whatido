//
//  SpendsListingView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 29/04/2025.
//

import SwiftUI

struct SpendsListingView: View {
    @EnvironmentObject var navigation: NavigationManager
    @StateObject var viewModel: SpendingsViewModel
    var body: some View {
        if viewModel.showMoreMonths {
            SpendingCalendarSplitView()
                .environmentObject(viewModel)
        } else {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total")
                                .font(.customFont(name: .medium, size: .x20))
                                .padding(.trailing, 5)
                            if viewModel.isDataLoading {
                                CircularLoadingIndicator()
                            } else {
                                HStack {
                                    Text("Rs")
                                        .font(.customFont(name: .regular, size: .x18))
                                    Text("\(viewModel.totalSpending)")
                                        .font(.customFont(name: .bold, size: .x30))
                                }
                            }
                        }
                        Spacer()
                        Button {
                            viewModel.showAddNewSpendingSheet.toggle()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(Color.primary)
                                .font(.title)
                        }
                    }.padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.2) , radius: 2, x: 0, y: 0.5)
                        }.padding()
                    if viewModel.isDataLoading {
                        CircularLoadingIndicator()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                    } else {
                        HStack {
                            Spacer()
                            SortingView(listing: viewModel.spendingSortTypes, pickedItem: $viewModel.selectedSortType)
                        }.padding(.horizontal)
                            .padding(.vertical, 5)
                        List {
                            ForEach(viewModel.currentMonthSpendings ?? [], id: \.self) { spending in
                                SpendingRow(spending: spending)
                                    .onTapGesture {
                                        viewModel.editSpending(spending)
                                    }
                                    .listRowInsets(EdgeInsets(top: 5, leading: 15, bottom: 10, trailing: 15)) // Customize spacing here
                            }
                            .onDelete(perform: viewModel.deleteSpending)
                            .listRowSeparator(.hidden)
                            .listRowSpacing(0)
                        }
                        .listStyle(PlainListStyle())
                        Spacer()
                    }
                }
            }.onAppear(perform: {
                guard viewModel.currentMonthSpendings == nil else {return}
                let date = Date().getFirstDateOfMonth()
                viewModel.fetchCurrentMonthSpendings(date: date)
            })
            .navigationTitle(viewModel.currentMonth)
          //  .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        print("Button tapped!")
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color.appPrimaryColor)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        self.viewModel.showMoreMonths.toggle()
                    }) {
                        Image(systemName: "calendar")
                            .foregroundStyle(Color.appPrimaryColor)
                    }
                }
            })
            .onChange(of: viewModel.showAddNewSpendingSheet) {old, new in
                if new == false {
                    viewModel.resetAddSpendingForm()
                    viewModel.tempSpending = nil
                }
            }.onChange(of: viewModel.selectedSortType) { _ , _ in
                viewModel.updatedSorting()
            }
            .alert("Confirm Deletion",
                     isPresented: $viewModel.showConfirmationAlert,
                     presenting: viewModel.spendingToDelete) { spending in
                  Button("Delete", role: .destructive) {
                      viewModel.confirmedDeleteSpending()
                  }
                  Button("Cancel", role: .cancel) {
                      viewModel.spendingToDelete = nil
                  }
              } message: { spending in
                  Text("Are you sure you want to delete spending?")
              }
            .sheet(isPresented: $viewModel.showAddNewSpendingSheet) {
                AddSpendingView()
                    .environmentObject(viewModel)
                    .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    SpendsListingView(viewModel: SpendingsViewModel())
}
