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
            GeometryReader { proxy in
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Total spendings")
                                        .foregroundStyle(Color.white)
                                        .font(.customFont(name: .medium, size: .x20))
                                        .padding(.trailing, 5)
                                    if viewModel.isDataLoading {
                                        CircularLoadingIndicator()
                                    } else {
                                        HStack {
                                            Text("Rs")
                                                .foregroundStyle(Color.white)
                                                .font(.customFont(name: .regular, size: .x18))
                                            Text("\(viewModel.totalSpending)")
                                                .foregroundStyle(Color.white)
                                                .font(.customFont(name: .bold, size: .x30))
                                        }
                                    }
                                }
                                Spacer()
                                Button {
                                    viewModel.showAddNewSpendingSheet.toggle()
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundStyle(Color.white)
                                        .font(.title)
                                }
                            }
                            HStack {
                                Spacer()
                                Button {
                                    
                                } label: {
                                    HStack {
                                        Text("View more")
                                            .foregroundStyle(Color.white)
                                            .font(.customFont(name: .medium, size:.x16))
                                        Image(systemName: "arrow.right")
                                            //.font(.title3)
                                            .foregroundStyle(Color.white)
                                            .frame(width: 10)
                                            .padding([.top, .leading], 2)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(Color.black)
                                .shadow(color: .black.opacity(0.2) , radius: 2, x: 0, y: 0.5)
                        }.padding()
                        if viewModel.isDataLoading {
                            CircularLoadingIndicator()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            HStack {
                                Spacer()
                                    MenuView(listing: viewModel.spendingSortTypes, icon: "line.3.horizontal.decrease", text: "Sort by", isPicker: true) { selectedOpt in
                                        viewModel.selectedSortType = selectedOpt
                                }
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
                        MenuView(listing: viewModel.menuOptions, icon: "ellipsis", rotation: 90) { selectedOpt in
                            viewModel.menuItemAction(selectedOpt)
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
}

#Preview {
    SpendsListingView(viewModel: SpendingsViewModel(spendingService: WhatISpendServiceStub()))
}
