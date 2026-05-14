import 'dart:async';
import 'dart:developer';

import 'package:injectable/injectable.dart';

const bool _logEventManager = false;

/// Связывает контроллеры между собой через события.
///
/// Паттерн **Publisher/Subscriber** (издатель-подписчик).
///
/// - Любой контроллер, выполняя действие, может создать событие (унаследовав класс от [Event]) и отправить его через [emit].
/// - Другие контроллеры могут подписываться на события через [on], чтобы выполнять побочные эффекты (side effects).
/// - Метод [on] возвращает объект [Action], который позволяет отписаться от события в любой момент.
///
/// ### Пример использования
///
/// ```dart
/// // Определяем событие
/// class UserLoggedInEvent extends Event {
///   const UserLoggedInEvent(super.data);
/// }
///
/// // Подписываемся
/// final action = eventManager.on<UserLoggedInEvent>((data) {
///   print('Пользователь вошёл: $data');
/// });
///
/// // Отправляем событие
/// eventManager.emit(UserLoggedInEvent('user@example.com'));
///
/// // Отписываемся при необходимости
/// await action.unsubscribe();
/// ```
@singleton
class EventManager {
  late final Stream<Event> _stream;
  late final StreamController<Event> _streamController;

  EventManager() {
    _streamController = StreamController<Event>.broadcast();
    _stream = _streamController.stream;
    log('[Event Manager] Initialized');
  }

  Action<T> on<T extends Event>(Function? callback) {
    late final Action<T> action;
    final Stream<T> stream = _stream.where((event) => event is T).cast<T>();

    action = Action<T>(
      subscription: stream.listen((event) {
        if (callback != null) {
          if (callback is Function(dynamic)) {
            callback(event.data);
          } else {
            callback();
          }
        }
      }),
    );

    if (_logEventManager) {
      log('[Event Manager] Subscribed on: $T');
    }

    return action;
  }

  void emit(Event event) {
    if (event.isLogged) {
      log('[Event Manager] Emitted: $event');
    }
    _streamController.add(event);
  }
}

//
// ACTION
//
class Action<T> implements IAction<T> {
  @override
  final StreamSubscription<T> subscription;

  const Action({required this.subscription});

  @override
  Future<void> unsubscribe() async {
    try {
      await subscription.cancel();
      if (_logEventManager) {
        log('[Event Manager] Unsubscribed: $T');
      }
    } catch (exception, stacktrace) {
      log(
        '[Event Manager] [Error] Unsubscribing $T: $exception',
        stackTrace: stacktrace,
      );
    }
  }
}

//
// EVENT
//
abstract class Event {
  final dynamic data;
  final bool isLogged = _logEventManager;
  const Event({this.data});
}

//
// ACTION INTERFACE
//
abstract interface class IAction<T> {
  StreamSubscription<T> get subscription;
  Future<void> unsubscribe();
}
