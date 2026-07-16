//
//  ExtensionAttendenceFilterView.swift
//  HR
//
//  Created by Esther Elzek on 09/07/2026.
//

import SwiftUI

extension AttendanceFilterView {
    @ViewBuilder
     func customeAtionTapped() -> some View {
        VStack(spacing: 16) {

            // From Date
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(NSLocalizedString("attendance.filter.date.from", comment: "From date label"))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    Spacer()

                    DatePicker(
                        "",
                        selection: Binding(
                            get: { tempFilter.customStartDate ?? Date() },
                            set: {
                                tempFilter.customStartDate = $0
                                validateDates()
                            }
                        ),
                        displayedComponents: .date
                    )
                    .colorScheme(.dark)
                    .accentColor(Color(attendanceAccentColor))
                }

                Divider()
                    .background(Color(attendanceAccentColor))
            }

            // To Date
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(NSLocalizedString("attendance.filter.date.to", comment: "To date label"))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    Spacer()

                    DatePicker(
                        "",
                        selection: Binding(
                            get: { tempFilter.customEndDate ?? Date() },
                            set: {
                                tempFilter.customEndDate = $0
                                validateDates()
                            }
                        ),
                        displayedComponents: .date
                    )
                    .colorScheme(.dark)
                    .accentColor(Color(attendanceAccentColor))
                }

                Divider()
                    .background(Color(attendanceAccentColor))
            }

            if showDateError {
                Text(NSLocalizedString("attendance.filter.date.error", comment: "Date validation error message"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.red)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    func validateDates() {
       guard let start = tempFilter.customStartDate,
             let end = tempFilter.customEndDate else {
           showDateError = false
           return
       }
       
       showDateError = start > end
   }

   
    @ViewBuilder
     func dayFilterView() -> some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text("Select Day")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding()
                Spacer()

                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .colorScheme(.dark)
                .accentColor(Color(attendanceAccentColor))
            }

            Divider()
                .background(Color(attendanceAccentColor))
                .padding()
        }
    }
    
    
    @ViewBuilder
     func weekFilterView() -> some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text("Select Week")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding()
                Spacer()

                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .colorScheme(.dark)
                .accentColor(Color(attendanceAccentColor))
            }

            Text("Choose any day within the week.")
                .font(.caption)
                .foregroundStyle(.gray)
                .padding()

            Divider()
                .background(Color(attendanceAccentColor))
                .padding()
        }
    }
    
    @ViewBuilder
     func monthFilterView() -> some View {

        VStack(spacing: 16) {

            HStack {

                Text("Month")
                    .foregroundStyle(.white)
                    .padding()
                Spacer()

                Picker("", selection: $selectedMonth) {

                    ForEach(1...12, id: \.self) { month in

                        Text(months[month - 1])
                            .tag(month)
                          
                           

                    }

                }
                .pickerStyle(.menu)
                .tint(Color(attendanceAccentColor))
               
              
            }

            Divider()
                .background(Color(attendanceAccentColor))
                .padding()

            HStack {

                Text("Year")
                    .foregroundStyle(.white)
                    .padding()
                Spacer()

                Picker("", selection: $selectedYear) {

                    ForEach(2020...2035, id: \.self) { year in

                        Text("\(year)")
                            .tag(year)

                    }

                }
                .pickerStyle(.menu)
                .tint(Color(attendanceAccentColor))
            }

            Divider()
                .background(Color(attendanceAccentColor))
                .padding()
        }
    }
    
    @ViewBuilder
     func quarterFilterView() -> some View {

        VStack(spacing: 16) {

            HStack {

                Text("Quarter")
                    .foregroundStyle(.white)
                    .padding()
                Spacer()

                Picker("", selection: $selectedQuarter) {

                    ForEach(Quarter.allCases) { quarter in

                        Text(quarter.title)
                            .tag(quarter)

                    }

                }
                .pickerStyle(.menu)
                .tint(Color(attendanceAccentColor))
            }

            Divider()
                .background(Color(attendanceAccentColor))
                .padding()

            HStack {

                Text("Year")
                    .foregroundStyle(.white)
                    .padding()

                Spacer()

                Picker("", selection: $selectedYear) {

                    ForEach(2020...2035, id: \.self) { year in

                        Text("\(year)")
                            .tag(year)

                    }

                }
                .pickerStyle(.menu)
                .tint(Color(attendanceAccentColor))
            }

            Divider()
                .background(Color(attendanceAccentColor))
                .padding()
        }
    }
    
    
    @ViewBuilder
     func yearFilterView() -> some View {

        VStack(alignment: .leading, spacing: 8) {

            HStack {

                Text("Year")
                    .foregroundStyle(.white)
                    .padding()
                Spacer()

                Picker("", selection: $selectedYear) {

                    ForEach(2020...2035, id: \.self) { year in

                        Text("\(year)")
                            .tag(year)

                    }

                }
                .pickerStyle(.menu)
                .tint(Color(attendanceAccentColor))
            }

            Divider()
                .background(Color(attendanceAccentColor))
                .padding()
        }
    }
    
    @ViewBuilder
     func actionsButtons() -> some View {
        HStack(spacing: 12) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    filter = tempFilter
                    isPresented = false
                }
            }) {
                Text(NSLocalizedString("attendance.filter.button.apply", comment: "Apply filter button"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color("greens"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(attendanceAccentColor))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    tempFilter = AttendanceFilter()
                    filter = AttendanceFilter()
                    isPresented = false
                }
            }) {
                Text(NSLocalizedString("attendance.filter.button.reset", comment: "Reset filter button"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.25, green: 0.25, blue: 0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}
