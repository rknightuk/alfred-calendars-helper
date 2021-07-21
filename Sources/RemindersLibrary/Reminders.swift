import EventKit
import Foundation

private let Store = EKEventStore()
private let dateFormatter = DateFormatter()
private func formattedDueDate(from reminder: EKReminder) -> String? {
    if reminder.dueDateComponents == nil { return "" }
    let dateformat = DateFormatter()
    dateformat.dateFormat = "yyyy-MM-dd HH:mm"
    return dateformat.string(from: reminder.dueDateComponents!.date ?? Date())
}

private func formattedDueDateEvent(from date: Date) -> String? {
    let dateformat = DateFormatter()
    dateformat.dateFormat = "yyyy-MM-dd HH:mm"
    return dateformat.string(from: date)
}

private func format(_ reminder: EKReminder, at index: Int) -> String {
    let dateString = formattedDueDate(from: reminder).map { "\($0)" } ?? ""
    return "{ \"id\": \"\(index)\", \"title\": \"\(reminder.title ?? "?")\", \"date\": \"\(dateString)\", \"list\": \"\(reminder.calendar.title)\" }"
}

private func formatEvent(_ event: EKEvent) -> String {
    let start = formattedDueDateEvent(from: event.startDate).map { "\($0)" } ?? ""
    let end = formattedDueDateEvent(from: event.endDate).map { "\($0)" } ?? ""
    let location = event.structuredLocation == nil ? "" : event.structuredLocation!.title!
    return "{ \"id\": \"\(event.eventIdentifier!)\", \"title\": \"\(event.title ?? "?")\", \"start\": \"\(start)\", \"end\": \"\(end)\", \"allDay\": \"\(event.isAllDay)\", \"location\": \"\(location)\", \"confirmed\": \"\(event.status == EKEventStatus.none || event.status == EKEventStatus.confirmed)\" }"
}

public final class Reminders {
    public static func requestAccess() -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var grantedAccess = false
        Store.requestAccess(to: .event) { granted, _ in
            grantedAccess = granted
            semaphore.signal()
        }

        semaphore.wait()
        return grantedAccess
    }

    func showCalendars() {
        let calendars = self.getCalendars()
        for calendar in calendars {
            print(calendar.title)
        }
    }

    func events(listName: String?) {
        let calendar = listName != nil ? self.calendar(withName: listName!) : nil
        let semaphore = DispatchSemaphore(value: 0)

        let now = Date()
        let nextFiveDays = Date(timeIntervalSinceNow: +5*24*3600)
        let calendars = calendar != nil ? [calendar!] : []

        let predicate = Store.predicateForEvents(withStart: now, end: nextFiveDays, calendars: calendars)

        let events = Store.events(matching: predicate)

        for event in events {
            print(formatEvent(event))
            semaphore.signal()
        }

        semaphore.wait()
    }

    func addReminder(string: String, toListNamed name: String, dueDate: DateComponents?) {
        let calendar = self.calendar(withName: name)
        let reminder = EKReminder(eventStore: Store)
        reminder.calendar = calendar
        reminder.title = string
        reminder.dueDateComponents = dueDate

        do {
            try Store.save(reminder, commit: true)
            print("Added '\(reminder.title!)' to '\(calendar.title)'")
        } catch let error {
            print("Failed to save reminder with error: \(error)")
            exit(1)
        }
    }

    // MARK: - Private functions

    private func reminders(onCalendar calendar: EKCalendar,
                                      completion: @escaping (_ reminders: [EKReminder]) -> Void)
    {
        let nextFiveDays = Date(timeIntervalSinceNow: +3*24*3600)
        let predicate = Store.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nextFiveDays, calendars: [calendar])
        Store.fetchReminders(matching: predicate) { reminders in
            var reminders = reminders?
                .filter { $0.dueDateComponents != nil }

            reminders = reminders!.sorted(by: { $0.dueDateComponents!.date ?? Date() < $1.dueDateComponents!.date ?? Date() })

            completion(reminders ?? [])
        }
    }

    private func calendar(withName name: String) -> EKCalendar {
        if let calendar = self.getCalendars().find(where: { $0.title.lowercased() == name.lowercased() }) {
            return calendar
        } else {
            print("No reminders list matching \(name)")
            exit(1)
        }
    }

    private func getCalendars() -> [EKCalendar] {
        return Store.calendars(for: .event)
                .filter { $0.allowsContentModifications }
    }
}
