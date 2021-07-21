# reminders-cli

A modified version of [reminders-cli](https://github.com/keith/reminders-cli) for use with [Calendar Events Alfred Workflow](https://github.com/rknightuk/alfred-workflows/tree/main/workflows/calendar-events)

## Usage:

#### Show all calendars

```
$ reminders calendars
Home
Work
```

#### Show events

```
$ reminders show Soon
All Day Thing
Lunch
```

#### Add event

```
$ reminders add "Home" "An event" -s "2021-07-22 12:00"
$ reminders add "Home" "An event" -s "2021-07-22 12:00" -e "2021-07-22 13:15"
$ reminders add "Home" "An event" -s "2021-07-22 12:00" -e "2021-07-22 13:15" -l "Star Labs"
```

### Installation

You don't want this, I promise you. It's only useful for the Alfred workflow.

#### Building manually

This requires a recent Xcode installation.

```
$ cd alfred-calendar-helper
$ make build-release
$ cp .build/release/reminders /usr/local/bin/reminders
```
