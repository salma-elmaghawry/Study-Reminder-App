/// Every notification has an id. Same id = replaces the old one,
/// and we use it to cancel ONE reminder without touching the others.
class ReminderIds {
  static const test = 0;
  static const quick = 1;
  static const daily = 2;
}
