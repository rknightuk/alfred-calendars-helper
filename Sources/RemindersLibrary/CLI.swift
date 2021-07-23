import ArgumentParser
import Foundation

private let reminders = Reminders()

private struct Events: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Show upcoming events")

    @Argument(
        help: "The calendar to show events from")
    var listName: String?

    @Option(
        name: .shortAndLong,
        help: "The amount of days to show")
    var limit: Int?

    func run() {
        reminders.events(listName: self.listName, limit: self.limit)
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
        help: "The calendar to add to, see 'calendars' for names")
    var listName: String

    @Argument(
        help: "The event title")
    var event: [String]

    @Option(
        name: .shortAndLong,
        help: "The date the event starts")
    var startDate: String

    @Option(
        name: .shortAndLong,
        help: "The date the event ends")
    var endDate: String?

    @Option(
        name: .shortAndLong,
        help: "The location of the event")
    var location: String?

    func run() {
        reminders.addEvent(
            string: self.event.joined(separator: " "),
            toListNamed: self.listName,
            startDate: self.startDate,
            endDate: self.endDate,
            location: self.location
        )
    }
}

public struct CLI: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "events",
        abstract: "Interact with macOS calendars from the command line",
        subcommands: [
            Add.self,
            Events.self,
            Calendars.self,
        ]
    )

    public init() {}
}
