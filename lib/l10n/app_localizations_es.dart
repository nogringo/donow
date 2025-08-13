// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Donow';

  @override
  String get signInTitle => 'Iniciar sesión en Donow';

  @override
  String get nsecLabel => 'Nsec';

  @override
  String get or => 'O';

  @override
  String get extensionLogin => 'Iniciar sesión con extensión';

  @override
  String get installExtension => 'Instalar extensión';

  @override
  String get create => 'Crear';

  @override
  String get whatToDo => '¿Qué tienes que hacer?';

  @override
  String get delete => 'Eliminar';

  @override
  String get profile => 'Perfil';

  @override
  String get updateAvailable => 'Actualización disponible';

  @override
  String get reloadThisPage => 'Recargar esta página';

  @override
  String get download => 'Descargar';

  @override
  String get active => 'Activas';

  @override
  String get completed => 'Completadas';

  @override
  String get noActiveTasks => 'Sin tareas activas';

  @override
  String get noCompletedTasks => 'Sin tareas completadas aún';

  @override
  String get markAsIncomplete => 'Marcar como incompleta';

  @override
  String get exportAsMarkdown => 'Exportar como Markdown';

  @override
  String get todosCopiedToClipboard => 'Tareas copiadas al portapapeles';

  @override
  String get failedToCopy => 'Error al copiar';

  @override
  String get todosDownloadedSuccessfully => 'Tareas descargadas exitosamente';

  @override
  String get failedToDownload => 'Error al descargar';

  @override
  String get clearAll => 'Borrar todo';

  @override
  String get deleteAllCompleted => 'Eliminar todas las completadas';

  @override
  String get deleteAllCompletedConfirmation =>
      '¿Estás seguro de que quieres eliminar todas las tareas completadas? Esta acción no se puede deshacer.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get blocked => 'Bloqueado';

  @override
  String get noBlockedTasks => 'No hay tareas bloqueadas';

  @override
  String get markAsBlocked => 'Marcar como bloqueado';

  @override
  String get unblock => 'Desbloquear';
}
