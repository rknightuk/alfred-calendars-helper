import ArgumentParser
import Foundation

private let reminders = Reminders()

private struct Events: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Show upcoming events")

    @Argument(
        help: "The calendar to show events from")
    var listName: String?

    func run() {
        reminders.events(listName: self.listName)
    }
}

private struct Calendars: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Show all calendars")

    func run() {
        reminders.showCalendars()
    }
}

private struct Add: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Add a event to a calendar")

    @Argument(
        help: "The list to add to, see 'show-lists' for names")
    var listName: String

    @Argument(
        parsing: .remaining,
        help: "The reminder contents")
    var reminder: [String]

    @Option(
        name: .shortAndLong,
        help: "The date the reminder is due")
    var dueDate: DateComponents?

    func run() {
        reminders.addReminder(
            string: self.reminder.joined(separator: " "),
            toListNamed: self.listName,
            dueDate: self.dueDate)
    }
}

public struct CLI: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "reminders",
        abstract: "Interact with macOS Reminders from the command line",
        subcommands: [
            Add.self,
            Events.self,
            Calendars.self,
        ]
    )

    public init() {}
}
