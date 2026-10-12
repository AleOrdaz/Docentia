import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';
import '../models/calendar_event_model.dart';

class CalendarEventsNotifier extends StateNotifier<AsyncValue<List<CalendarEvent>>> {
  CalendarEventsNotifier() : super(const AsyncValue.loading()) {
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      final events = await StorageService.getCalendarEvents();
      state = AsyncValue.data(events);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<CalendarEvent> addEvent({
    required String title,
    required String description,
    required String date,
    required String startTime,
    String? endTime,
    String? location,
    List<String> emailRecipients = const [],
    String? reminder,
  }) async {
    final newEvent = CalendarEvent(
      id: 'event-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      date: date,
      startTime: startTime,
      endTime: endTime,
      location: location,
      emailRecipients: emailRecipients,
      reminder: reminder,
      createdAt: DateTime.now(),
    );

    final current = state.value ?? [];
    final updated = [newEvent, ...current];
    state = AsyncValue.data(updated);
    await StorageService.saveCalendarEvents(updated);
    return newEvent;
  }

  Future<void> deleteEvent(String id) async {
    final current = state.value ?? [];
    final updated = current.where((e) => e.id != id).toList();
    state = AsyncValue.data(updated);
    await StorageService.saveCalendarEvents(updated);
  }
}

final calendarEventsProvider =
StateNotifierProvider<CalendarEventsNotifier, AsyncValue<List<CalendarEvent>>>((ref) {
  return CalendarEventsNotifier();
});
