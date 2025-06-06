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
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Current Spendings")
                            .font(.customFont(name: .medium, size: .x18))
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
                        ForEach(viewModel.spendings ?? [], id: \.self) { spending in
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
            viewModel.fetchSpendings()
        })
        // TODO: - Will move add button in toolbar when navigation will added
//        .toolbar(content: {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                              Button(action: {
//                                  // Code for button action goes here
//                                  print("Button tapped!")
//                              }) {
//                                  Text("Add")
//                                  // Or use an image:
//                                  // Image(systemName: "plus.circle.fill")
//                              }
//                          }
//        })
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

#Preview {
    SpendsListingView(viewModel: SpendingsViewModel())
}
