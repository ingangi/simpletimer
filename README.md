# simpletimer

A concise timed reminder tool.

## Getting Started

You can set timers in different types:

```dart
enum TimerType {
  single, // a single timepoint
  daily, // daily timer
  weekDaily, // week day timer
  monthly, // month day timer
  yearly, // year day timer
  interval, // repeat after some interval
}
```
