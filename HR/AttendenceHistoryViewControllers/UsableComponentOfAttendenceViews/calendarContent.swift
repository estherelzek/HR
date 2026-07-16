//
//  calendarContent.swift
//  HR
//
//  Created by Esther Elzek on 25/06/2026.
//

import SwiftUI

import SwiftUI


struct calendarContent: View {

    let entries: [AttendanceHistoryEntry]

    @State private var currentMonth = Date()


    init(entries: [AttendanceHistoryEntry] = AttendanceHistoryEntry.demoEntries) {
        self.entries = entries
    }


    var body: some View {

        ScrollView(showsIndicators: false) {

            VStack(alignment: .leading, spacing: 16) {


                HStack {

                    Button {
                        changeMonth(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.white)
                    }


                    Spacer()


                    Text(monthTitle)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)


                    Spacer()


                    Button {
                        changeMonth(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.white)
                    }

                }
                .padding(.horizontal,20)



                MonthCalendarView(
                    month: currentMonth,
                    entries: entries
                )
                .padding(.horizontal,12)




                VStack(spacing:10) {

                    ForEach(entries.prefix(3)) { entry in


                        HStack(spacing:12) {


                            statusDot(for: entry.status)
                                .frame(width:12,height:12)



                            Text(entry.dateText)
                                .foregroundStyle(.white)
                                .font(.system(size:16,weight:.medium))


                            Spacer()



                            Text(entry.status.title.uppercased())
                                .foregroundStyle(
                                    Color(entry.status.tintColor)
                                )
                                .font(
                                    .system(
                                        size:14,
                                        weight:.bold
                                    )
                                )
                        }

                        .padding(.horizontal,20)
                        .padding(.vertical,14)
                        .background(
                            Color(
                                red:0.12,
                                green:0.12,
                                blue:0.12
                            )
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius:18
                            )
                        )
                    }

                }
                .padding(.horizontal,18)



            }
            .padding(.top,6)
            .padding(.bottom,28)

        }

        .background(Color.black)

    }



    private var monthTitle:String {

        currentMonth.formatted(
            .dateTime
                .month(.wide)
                .year()
        )

    }



    private func changeMonth(by value:Int) {

        if let newDate =
            Calendar.current.date(
                byAdding:.month,
                value:value,
                to:currentMonth
            ) {

            currentMonth = newDate

        }

    }


}




// MARK: - Month Calendar


private struct MonthCalendarView:View {


    let month:Date
    let entries:[AttendanceHistoryEntry]


    private let columns =
    Array(
        repeating: GridItem(.flexible(), spacing:8),
        count:7
    )



    var body: some View {


        VStack(spacing:10) {


            HStack {


                ForEach(
                    ["S","M","T","W","T","F","S"],
                    id:\.self
                ) { day in


                    Text(day)
                        .font(
                            .system(
                                size:13,
                                weight:.bold
                            )
                        )
                        .foregroundStyle(
                            Color.white.opacity(0.58)
                        )
                        .frame(maxWidth:.infinity)

                }

            }



            LazyVGrid(
                columns:columns,
                spacing:8
            ) {


                ForEach(
                    calendarDays,
                    id:\.self
                ) { day in


                    CalendarDayCell(
                        date:day,
                        entry:entry(for:day)
                    )

                }


            }


        }

        .padding(16)

        .background(
            Color(
                red:0.12,
                green:0.12,
                blue:0.12
            )
        )

        .clipShape(
            RoundedRectangle(
                cornerRadius:20
            )
        )

    }





    private var calendarDays: [Date?] {

        let calendar = Calendar.current

        guard let monthRange =
                calendar.range(
                    of: .day,
                    in: .month,
                    for: month
                )
        else {
            return []
        }


        let firstDay =
        calendar.component(
            .weekday,
            from:
                calendar.date(
                    from:
                        calendar.dateComponents(
                            [.year, .month],
                            from: month
                        )
                )!
        )


        let empty: [Date?] =
            Array(
                repeating: nil,
                count: firstDay - 1
            )


        let days: [Date?] =
            monthRange.map {
                calendar.date(
                    byAdding: .day,
                    value: $0 - 1,
                    to: month
                )
            }


        return empty + days
    }


    private func entry(
        for date:Date?
    ) -> AttendanceHistoryEntry? {


        guard let date else {
            return nil
        }


        let day =
        Calendar.current.component(
            .day,
            from:date
        )


        return entries.first {

            $0.date.day == day

        }

    }

}







// MARK: - Day Cell


private struct CalendarDayCell:View {


    let date:Date?
    let entry:AttendanceHistoryEntry?



    var body: some View {


        ZStack {


            RoundedRectangle(
                cornerRadius:14
            )

            .fill(
                Color.white.opacity(
                    entry == nil ? 0.03 : 0.08
                )
            )

            .frame(height:46)




            if let date {


                VStack(spacing:4) {


                    Text(
                        "\(dayNumber(date))"
                    )

                    .font(
                        .system(
                            size:15,
                            weight:.semibold
                        )
                    )

                    .foregroundStyle(.white)





                    if let entry {


                        Circle()

                            .fill(
                                Color(
                                    entry.status.tintColor
                                )
                            )

                            .frame(
                                width:7,
                                height:7
                            )

                    }

                }


            }


        }


    }



    private func dayNumber(_ date:Date)->Int {


        Calendar.current.component(
            .day,
            from:date
        )

    }

}







private func statusDot(
    for status:AttendanceStatus
)->some View {


    Circle()
        .fill(
            Color(status.tintColor)
        )

}







#Preview {

    calendarContent()

}
