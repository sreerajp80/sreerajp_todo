// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sanskrit (`sa`).
class AppLocalizationsSa extends AppLocalizations {
  AppLocalizationsSa([String locale = 'sa']) : super(locale);

  @override
  String get appName => 'SreerajP ToDo';

  @override
  String get dailyList => 'मम कार्याणि';

  @override
  String get createTodo => 'नूतनं कार्यम्';

  @override
  String get editTodo => 'कार्यं सम्पाद्यताम्';

  @override
  String get timeSegments => 'समयखण्डाः';

  @override
  String get copyTodos => 'कार्याणि प्रतिलिख्यन्ताम्';

  @override
  String get searchResults => 'अन्वेषणपरिणामाः';

  @override
  String get recurringTasks => 'पुनरावृत्तिकार्याणि';

  @override
  String get newRecurrence => 'नूतनपुनरावृत्तिनियमः';

  @override
  String get editRecurrence => 'पुनरावृत्तिनियमः सम्पाद्यताम्';

  @override
  String get statistics => 'साङ्ख्यिकी';

  @override
  String get titleHint => 'कार्यशीर्षकं लिख्यताम्';

  @override
  String get descriptionHint => 'वर्णनं लिख्यताम् (वैकल्पिकम्)';

  @override
  String get searchHint => 'कार्याण्यन्विष्यन्ताम्...';

  @override
  String get noTodosForDay => 'अस्मिन् दिने कार्याणि न सन्ति';

  @override
  String get noSearchResults => 'परिणामाः न प्राप्ताः';

  @override
  String get titleRequired => 'शीर्षकम् आवश्यकम्';

  @override
  String get addFirstTask => 'प्रथमं कार्यं योज्यताम्';

  @override
  String get noTasksTodayTitle => 'अद्य कार्याणि न सन्ति';

  @override
  String get noTasksTodayMessage =>
      'दिनस्य योजनां कर्तुं प्रथमं कार्यं योज्यताम्।';

  @override
  String get noTasksForPastDayMessage => 'अस्मिन् दिने कार्याणि न पञ्जीकृतानि।';

  @override
  String get searchTasksTitle => 'कार्याण्यन्विष्यन्ताम्';

  @override
  String get searchTasksMessage =>
      'दिनेष्वन्वेष्टुं शीर्षकं विवरणं वा लिख्यताम्।';

  @override
  String get noStatisticsData =>
      'साङ्ख्यिकीं द्रष्टुं कार्याणां समयगणनं प्रारभ्यताम्';

  @override
  String get noRecurringTasksDetailed =>
      'पुनरावृत्तिकार्याणि न सन्ति। स्वयञ्चालनार्थं नियमं सृज्यताम्।';

  @override
  String get noSegmentsRecordedDetailed =>
      'इतिवृत्तं द्रष्टुं समयं गणयतु हस्तचालितखण्डं वा योजयतु।';

  @override
  String get backupDirectory => 'प्रतिरक्षापुटम्';

  @override
  String get previousDay => 'पूर्वदिनम्';

  @override
  String get nextDay => 'अग्रिमदिनम्';

  @override
  String get openCalendar => 'दिनदर्शिका उद्घाट्यताम्';

  @override
  String get clearSearch => 'अन्वेषणं रिक्तीक्रियताम्';

  @override
  String get toggleSelection => 'चयनं परिवर्त्यताम्';

  @override
  String get openTaskActions => 'कार्यक्रियाः उद्घाट्यन्ताम्';

  @override
  String get lockedTask => 'कीलितं कार्यम्';

  @override
  String get manualSegmentShort => 'ह';

  @override
  String get emptyValue => '—';

  @override
  String get day => 'दिनम्';

  @override
  String get details => 'विवरणम्';

  @override
  String get taskStatus => 'स्थितिः';

  @override
  String get statusPending => 'अवशिष्टम्';

  @override
  String get statusWorking => 'प्रवर्तमानम्';

  @override
  String get statusCompleted => 'समापितम्';

  @override
  String get statusDropped => 'त्यक्तम्';

  @override
  String get statusPorted => 'स्थानान्तरितम्';

  @override
  String get completeAction => 'समाप्यताम्';

  @override
  String get reopenAction => 'पुनरुद्घाट्यताम्';

  @override
  String get dropAction => 'त्यज्यताम्';

  @override
  String get confirmDrop => 'इदं कार्यं त्यज्यतां वा?';

  @override
  String get confirmDropBody =>
      'इदं कार्यं त्यक्तमिति चिह्निष्यते। व्यतीतः समयः त्यक्तसमयत्वेन गणयिष्यते।';

  @override
  String get confirmPort => 'इदं कार्यं स्थानान्तर्यतां वा?';

  @override
  String get confirmPortBody => 'इदं कार्यं चितदिनाङ्के स्थानान्तरयिष्यते।';

  @override
  String get confirmDelete => 'इदं कार्यं लुप्यतां वा?';

  @override
  String get confirmDeleteBody =>
      'इदं कार्यं तस्य सर्वे समयखण्डाश्च सर्वथा लोप्स्यन्ते।';

  @override
  String get confirmDeleteRecurring => 'पुनरावृत्तिकार्यं लुप्यतां वा?';

  @override
  String get confirmDeleteRecurringBody =>
      'इदं कार्यं पुनरावृत्तिनियमेन निर्मितम्।';

  @override
  String get deleteOnlyThis => 'केवलं तदेव लुप्यताम्';

  @override
  String get deleteThisAndFuture => 'इदम् आगामिकार्याणि च लुप्यन्ताम्';

  @override
  String get deleteAllOccurrences => 'सर्वाः आवृत्तयः लुप्यन्ताम्';

  @override
  String get allOccurrencesDeleted => 'सर्वाः आवृत्तयः लुप्ताः।';

  @override
  String get futureOccurrencesDeleted => 'इदम् आगामिकार्याणि च लुप्तानि।';

  @override
  String get confirmEditRecurring => 'पुनरावृत्तिकार्यं सम्पाद्यताम्';

  @override
  String get confirmEditRecurringBody =>
      'इदं कार्यं पुनरावृत्तिनियमेन सम्बद्धम्। परिवर्तनानि कथं प्रयोक्तव्यानि?';

  @override
  String get editOnlyThis => 'केवलं तदेव सम्पाद्यताम्';

  @override
  String get editThisAndFuture => 'इदम् आगामिकार्याणि च सम्पाद्यन्ताम्';

  @override
  String get editAllOccurrences => 'सर्वाः आवृत्तयः सम्पाद्यन्ताम्';

  @override
  String get deleteTimeSegment => 'समयखण्डं लोप्यताम्';

  @override
  String get confirmDeleteSegment => 'अयं समयखण्डः लुप्यतां वा?';

  @override
  String get confirmDeleteSegmentBody => 'अयं समयखण्डः सर्वथा लोप्स्यते।';

  @override
  String get timeSegmentDeleted => 'समयखण्डः लुप्तः';

  @override
  String get confirmBulkDrop => 'चितानि कार्याणि त्यज्यन्तां वा?';

  @override
  String get confirmBulkDropBody =>
      'चितानि कार्याणि त्यक्तानि इति चिह्निष्यन्ते।';

  @override
  String get confirm => 'स्थिरीक्रियताम्';

  @override
  String get cancel => 'निरस्यताम्';

  @override
  String get save => 'रक्ष्यताम्';

  @override
  String get delete => 'लुप्यताम्';

  @override
  String get undo => 'प्रत्यावर्त्यताम्';

  @override
  String get edit => 'सम्पाद्यताम्';

  @override
  String get port => 'स्थानान्तर्यताम्';

  @override
  String get copy => 'प्रतिलिख्यताम्';

  @override
  String get retry => 'पुनः प्रयत्यताम्';

  @override
  String get today => 'अद्य';

  @override
  String get selectTargetDate => 'लक्ष्यदिनाङ्कं चिनोतु';

  @override
  String get completeAll => 'सर्वाणि समाप्यन्ताम्';

  @override
  String get markDropped => 'त्यक्तमिति चिह्नीयताम्';

  @override
  String get selectAll => 'सर्वं चीयताम्';

  @override
  String get deselectAll => 'सर्वं मुच्यताम्';

  @override
  String get copyToAnotherDay => 'अन्यदिने प्रतिलिख्यताम्';

  @override
  String get previous => 'पूर्वम्';

  @override
  String get copiedFrom => 'इतः प्रतिलिखितम्';

  @override
  String get portedTo => 'अत्र स्थानान्तरितम्';

  @override
  String get noDescription => 'वर्णनं नास्ति';

  @override
  String get startTimer => 'समयगणनम् आरभ्यताम्';

  @override
  String get stopTimer => 'समयगणनं विरम्यताम्';

  @override
  String get timerRunning => 'समयगणनं प्रवर्तते';

  @override
  String get addManualSegment => 'हस्तचालितखण्डं योज्यताम्';

  @override
  String get manualSegmentAdded => 'हस्तचालितखण्डः योजितः';

  @override
  String get segmentStart => 'आरम्भः';

  @override
  String get segmentEnd => 'समाप्तिः';

  @override
  String get segmentType => 'प्रकारः';

  @override
  String get segmentDuration => 'अवधिः';

  @override
  String get segmentNoteLabel => 'टिप्पणी (वैकल्पिकी)';

  @override
  String get segmentNoteHint => 'किं कार्यं कृतम्?';

  @override
  String get editSegmentNote => 'टिप्पणी सम्पाद्यताम्';

  @override
  String matchedInNote(String note) {
    return 'टिप्पणी: $note';
  }

  @override
  String get segmentAuto => 'स्वचालितम्';

  @override
  String get segmentManual => 'हस्तचालितम्';

  @override
  String get segmentRunning => 'प्रवर्तमानम्';

  @override
  String get segmentInterruptedTooltip =>
      'इदं समयगणनम् असाधारणेन रूपेण स्थगितम्।';

  @override
  String get totalTime => 'कुलसमयः';

  @override
  String get viewSegments => 'समयखण्डाः दृश्यन्ताम्';

  @override
  String get noSegments => 'समयखण्डाः न सन्ति';

  @override
  String get startBeforeEnd => 'आरम्भसमयः समाप्तिसमयात् पूर्वं भवेत्।';

  @override
  String get segmentOverlap => 'अयं खण्डः विद्यमानेन खण्डेन सह व्याप्नोति।';

  @override
  String get segmentMustBeSameDay => 'समयखण्डः एकस्मिन्नेव दिने भवेत्।';

  @override
  String get statusChangedTo => 'अस्यां स्थितौ परिवर्तिता';

  @override
  String get undoStatusChange => 'प्रत्यावर्त्यताम्';

  @override
  String get bulkStatusChanged => 'कार्याणि नवीकृतानि';

  @override
  String get todoCreated => 'कार्यं सृष्टम्';

  @override
  String get todoUpdated => 'कार्यम् अद्यतनीकृतम्';

  @override
  String get todoDeleted => 'कार्यं लुप्तम्';

  @override
  String get todoPorted => 'कार्यं स्थानान्तरितम्';

  @override
  String get todosCopied => 'कार्याणि प्रतिलिखितानि';

  @override
  String get todosSkipped => 'उपेक्षितानि (द्विरुक्तशीर्षकम्)';

  @override
  String get stepSelectItems => 'कार्याणि चिनोतु';

  @override
  String get stepPickDate => 'दिनाङ्कं चिनोतु';

  @override
  String get stepPreview => 'पूर्वावलोकनम्';

  @override
  String get next => 'अग्रिमम्';

  @override
  String get back => 'प्रत्यागमनम्';

  @override
  String get copyConfirm => 'प्रतिलेखनस्य स्थिरीकरणम्';

  @override
  String get noItemsSelected => 'किमपि कार्यं न चितम्';

  @override
  String get willBeSkipped => 'उपेक्षिष्यते';

  @override
  String get itemsToCopy => 'प्रतिलेखनीयानि कार्याणि';

  @override
  String get itemsWillBeSkipped => 'उपेक्षणीयानि कार्याणि';

  @override
  String get targetDate => 'लक्ष्यदिनाङ्कः';

  @override
  String get sourceDate => 'मूलदिनाङ्कः';

  @override
  String get selectDateFirst => 'प्रथमं दिनाङ्कं चिनोतु';

  @override
  String get viewTodo => 'कार्यं दृश्यताम्';

  @override
  String get readOnlyPastDate => 'व्यतीतदिनानि केवलं द्रष्टुं शक्यन्ते';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चितानि',
      one: '1 चितम्',
    );
    return '$_temp0';
  }

  @override
  String noSearchResultsForQuery(String query) {
    return '\"$query\" कृते परिणामाः न प्राप्ताः';
  }

  @override
  String statusSemantics(String status) {
    return 'कार्यस्थितिः $status';
  }

  @override
  String totalTimeForTask(String title, String duration) {
    return '$title इत्यस्य कुलसमयः $duration';
  }

  @override
  String startTimerForTask(String title) {
    return '$title कृते समयगणनम् आरभ्यताम्';
  }

  @override
  String stopTimerForTask(String title) {
    return '$title कृते समयगणनं विरम्यताम्';
  }

  @override
  String runningTimerForTask(String title) {
    return '$title कृते समयगणनं प्रवर्तते';
  }

  @override
  String segmentSemantics(
    int index,
    String start,
    String end,
    String duration,
    String type,
  ) {
    return 'खण्डः $index। $start तः $end पर्यन्तम्। अवधिः $duration। प्रकारः $type।';
  }

  @override
  String get repeat => 'पुनरावृत्तिः';

  @override
  String get repeatNone => 'कदापि न';

  @override
  String get repeatConfigure => 'पुनरावृत्तिं विरचयतु';

  @override
  String get recurrenceCreated => 'पुनरावृत्तिनियमः सृष्टः';

  @override
  String get startDate => 'आरम्भदिनाङ्कः';

  @override
  String get endDate => 'समाप्तिदिनाङ्कः';

  @override
  String get ends => 'समाप्तिः';

  @override
  String get endsNever => 'कदापि न';

  @override
  String get endsOnDate => 'दिनाङ्के';

  @override
  String get endsAfterDays => 'तावद्दिनेभ्यः';

  @override
  String get frequency => 'आवृत्तिः';

  @override
  String get daily => 'प्रतिदिनम्';

  @override
  String get weekly => 'प्रतिसप्ताहम्';

  @override
  String get monthly => 'प्रतिमासम्';

  @override
  String get yearly => 'प्रतिवर्षम्';

  @override
  String get every => 'प्रत्येकम्';

  @override
  String get days => 'दिनानि';

  @override
  String get weeks => 'सप्ताहाः';

  @override
  String get months => 'मासाः';

  @override
  String get years => 'वर्षाणि';

  @override
  String get daysOfWeek => 'सप्ताहस्य दिनानि';

  @override
  String get nextOccurrences => 'अग्रिमाः आवृत्तयः';

  @override
  String get noUpcomingOccurrences => 'आगामिन्यः आवृत्तयः न सन्ति';

  @override
  String get monday => 'सोमवासरः';

  @override
  String get tuesday => 'मङ्गलवासरः';

  @override
  String get wednesday => 'बुधवासरः';

  @override
  String get thursday => 'गुरुवासरः';

  @override
  String get friday => 'शुक्रवासरः';

  @override
  String get saturday => 'शनिवासरः';

  @override
  String get sunday => 'रविवासरः';

  @override
  String get sortTodos => 'कार्याणि क्रमीक्रियन्ताम्';

  @override
  String get sortManual => 'हस्तचालितम्';

  @override
  String get sortNameAZ => 'नाम (अकारादौ)';

  @override
  String get sortNameZA => 'नाम (प्रतिलोमम्)';

  @override
  String get sortCreatedOldest => 'सृष्टिक्रमः (पुरातनं प्रथमम्)';

  @override
  String get sortCreatedNewest => 'सृष्टिक्रमः (नवीनं प्रथमम्)';

  @override
  String get sortTimeMost => 'व्यतीतः समयः (अधिकं प्रथमम्)';

  @override
  String get sortTimeLeast => 'व्यतीतः समयः (अल्पं प्रथमम्)';

  @override
  String get sortByStatus => 'स्थित्यनुसारम्';

  @override
  String get backupLabel => 'प्रतिरक्षा';

  @override
  String get backupExportTitle => 'प्रतिरक्षां निर्यापयतु';

  @override
  String get backupImportTitle => 'प्रतिरक्षामन्तः आनयतु';

  @override
  String get backupPassphraseLabel => 'गुप्तपदम्';

  @override
  String get backupPassphraseConfirmLabel => 'गुप्तपदं स्थिरीकुरुत';

  @override
  String get backupPassphraseMinLength =>
      'गुप्तपदे न्यूनातिन्यूनम् ८ अक्षराणि भवेयुः';

  @override
  String get backupPassphraseMismatch => 'गुप्तपदे परस्परं न समेते';

  @override
  String get backupPassphraseWarning =>
      'इदं गुप्तपदं स्मर्तव्यम्। एतद्विना प्रतिरक्षा न पुनरुद्धरिष्यते।';

  @override
  String get backupExportSuccess => 'प्रतिरक्षा साफल्येन निर्यापिता';

  @override
  String get backupImportConfirmTitle => 'पुनःस्थापनस्थिरीकरणम्';

  @override
  String get backupImportConfirmMessage =>
      'वर्तमानदत्तांशः नष्टो भूत्वा प्रतिरक्षादत्तांशेन प्रतिस्थाप्स्यते।';

  @override
  String get backupImportSuccess => 'प्रतिरक्षा साफल्येन पुनःस्थापिता';

  @override
  String get backupImportWrongPassphrase =>
      'गुप्तपदमशुद्धं वा सञ्चिका विकृता वा';

  @override
  String get backupImportVersionTooNew =>
      'इयं सञ्चिका नूतनसंस्करणाय अस्ति। पूर्वम् अभियोगम् अद्यतनीकुरुत।';

  @override
  String get backupImportCorrupted =>
      'प्रतिरक्षासञ्चिका विकृता, अतः पुनःस्थापयितुं न शक्यते।';

  @override
  String get backupDeleteBackupConfirm => 'इयं प्रतिरक्षा लुप्यतां वा?';

  @override
  String get backupNoBackupsFound => 'प्रतिरक्षाः न प्राप्ताः';

  @override
  String get backupNoBackupsFoundDetailed =>
      'प्रतिरक्षा न प्राप्ता। दत्तांशसुरक्षार्थं प्रथमां प्रतिरक्षां निर्यापयतु।';

  @override
  String get backupRecentBackups => 'सद्यःकालीनाः प्रतिरक्षाः';

  @override
  String get backupChooseDestination => 'प्रतिरक्षापुटं चिनोतु';

  @override
  String get backupSelectBackupFile => 'प्रतिरक्षासञ्चिकां चिनोतु';

  @override
  String get backupDeleteSuccess => 'प्रतिरक्षा लुप्ता';

  @override
  String get backupExportInProgress => 'प्रतिरक्षा निर्याप्यते...';

  @override
  String get backupImportInProgress => 'प्रतिरक्षा पुनःस्थाप्यते...';

  @override
  String get backupHealthDashboardTitle => 'प्रतिरक्षास्वास्थ्यपटलम्';

  @override
  String get backupHealthStatusHealthy => 'स्वस्थम्';

  @override
  String get backupHealthStatusWarning => 'अवधानम् आवश्यकम्';

  @override
  String get backupHealthStatusNoBackups => 'प्रतिरक्षा न सृष्टा';

  @override
  String get backupHealthLogsTitle => 'निदानवृत्तयः';

  @override
  String get backupHealthTriggerManual => 'हस्तचालितम्';

  @override
  String get backupHealthTriggerScheduled => 'नियतकालम्';

  @override
  String get backupHealthStatusSuccess => 'सफलम्';

  @override
  String get backupHealthStatusFailed => 'असफलम्';

  @override
  String get settingsLabel => 'विन्यासः';

  @override
  String get settingsAppearance => 'दृश्यरूपम्';

  @override
  String get settingsThemeMode => 'वर्णक्रमः';

  @override
  String get settingsFollowSystem => 'तन्त्रसिद्धम्';

  @override
  String get settingsLight => 'दीप्तरूपम्';

  @override
  String get settingsDark => 'श्यामरूपम्';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsLanguageSystem => 'तन्त्रसिद्धम्';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageMalayalam => 'മലയാളം';

  @override
  String get settingsLanguageSanskrit => 'संस्कृतम्';

  @override
  String get settingsShortcuts => 'लघुमार्गाः';

  @override
  String get settingsAboutApp => 'विषयपरिचयः';

  @override
  String get settingsPermissions => 'अनुमतयः';

  @override
  String get settingsOfflineTitle => 'असंयुक्तं गोपनीयं च';

  @override
  String get settingsOfflineBody =>
      'इदमभियोगं सर्वथा जालरहितं प्रवर्तते। भवतः कार्याणि, इतिवृत्तं, साङ्ख्यिकी च यन्त्रान्तः एव सुरक्षितानि।';

  @override
  String get settingsAppearanceSubtitle =>
      'वर्णक्रमः, अक्षरशैली, प्रधानवर्णश्च';

  @override
  String get settingsLanguageSubtitle => 'अभियोगे प्रयुक्तां भाषां चिनोतु';

  @override
  String get settingsBackupSubtitle => 'सञ्चिकायां सुरक्षितरक्षणम्';

  @override
  String get settingsFeatures => 'सविशेषांशाः';

  @override
  String get settingsFeaturesSubtitle =>
      'SreerajP ToDo इत्यस्य सर्वान् विशेषांशान् पश्यतु';

  @override
  String get settingsHelp => 'साहाय्यं मार्गदर्शिकाश्च';

  @override
  String get settingsHelpSubtitle => 'समयगणनं, समकालनं, प्रतिरक्षा, प्रश्नाश्च';

  @override
  String get settingsAboutSubtitle => 'संस्करणम्, श्रेयः, अभियोगविवरणं च';

  @override
  String get settingsTimeTracking => 'समयगणनम्';

  @override
  String get settingsTimeTrackingSubtitle =>
      'स्वचालितविरामः, पोमोडोरो, समयप्रकाशनं च';

  @override
  String get trackingAutoStop => 'स्वचालितविरामः';

  @override
  String get trackingAutoStopSubtitle =>
      'अतिदीर्घकालं यावत् प्रवर्तमानं समयगणनं स्वयमेव विरम्यताम्';

  @override
  String get trackingAutoStopOff => 'कदापि न';

  @override
  String get trackingAutoStopOffDetail =>
      'यावत् भवान् न विरमति तावत् समयगणकं प्रवर्तते।';

  @override
  String get trackingAutoStopMidnight => 'मध्यरात्रौ';

  @override
  String get trackingAutoStopMidnightDetail =>
      'दिनावसाने विरमति येन समयः न नश्यति।';

  @override
  String get trackingAutoStopCustom => 'चितसमये';

  @override
  String get trackingAutoStopCustomDetail => 'अधस्तनचितसमये विरमति।';

  @override
  String get trackingAutoStopTime => 'विरामसमयः';

  @override
  String get trackingAutoStopNote =>
      'अभियोगे पिहिते सति तस्मिन्नेव क्षणे समयगणकं स्थगयितुं न शक्यते। पुनरुद्घाटने तत् संशोध्यते।';

  @override
  String get trackingAutoStopped => 'समयगणकं स्वयमेव विरतम्';

  @override
  String get trackingTimerBehaviour => 'समयगणकस्य वृत्तिः';

  @override
  String get trackingTimerBehaviourSubtitle =>
      'एकसमये एकं, विरामः, पटलं, लघुखण्डाश्च';

  @override
  String get trackingSingleTimer => 'एकसमये एकमेव समयगणकम्';

  @override
  String get trackingSingleTimerDetail =>
      'नूतनसमयगणकस्यारम्भे अन्यकार्ये प्रवर्तमानं विरमति।';

  @override
  String trackingStoppedOtherCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अन्यानि समयगणनानि विरतानि',
      one: '1 अन्यत् समयगणनं विरतम्',
    );
    return '$_temp0';
  }

  @override
  String get trackingAutoPause => 'अभियोगे पिहिते स्थग्यताम्';

  @override
  String get trackingAutoPauseDetail =>
      'अभियोगत्यागे समयगणकं स्थग्यते। व्यतीतः समयः रक्ष्यते।';

  @override
  String get trackingKeepScreenAwake => 'पटलं दीप्तं स्थाप्यताम्';

  @override
  String get trackingKeepScreenAwakeDetail =>
      'समयगणने प्रवर्तमाने पटलं दीप्तं तिष्ठति। केवलाण्ड्राय्ड्-यन्त्रे।';

  @override
  String get trackingMinimumLength => 'रक्षणीयः कनिष्ठखण्डः';

  @override
  String get trackingMinimumLengthDetail =>
      'इतोऽपि शीघ्रमवसिते सति खण्डः उपेक्ष्यते येन इतिवृत्तं स्वच्छं तिष्ठति।';

  @override
  String get trackingMinimumOff => 'सर्वं रक्ष्यताम्';

  @override
  String get trackingMinimum10s => '१० क्षणाभ्यन्तरे';

  @override
  String get trackingMinimum30s => '३० क्षणाभ्यन्तरे';

  @override
  String get trackingMinimum1m => '१ निमेषाभ्यन्तरे';

  @override
  String get trackingMinimum5m => '५ निमेषाभ्यन्तरे';

  @override
  String get trackingSegmentDiscarded => 'खण्डः अतिलघुत्वात् न रक्षितः';

  @override
  String get trackingPomodoro => 'पोमोडोरो';

  @override
  String get trackingPomodoroSubtitle => 'ध्यानखण्डाः विरामाश्च';

  @override
  String get trackingPomodoroEnabled => 'ध्यानखण्डाः प्रयुज्यन्ताम्';

  @override
  String get trackingPomodoroEnabledDetail =>
      'प्रवर्तमानः समयगणकः स्वयमेव समाप्तभवन् कार्यखण्डः भवति।';

  @override
  String get trackingPomodoroWork => 'कार्यखण्डः';

  @override
  String get trackingPomodoroShortBreak => 'लघुविरामः';

  @override
  String get trackingPomodoroLongBreak => 'दीर्घविरामः';

  @override
  String get trackingPomodoroBlocks => 'दीर्घविरामाय खण्डसङ्ख्या';

  @override
  String get trackingPomodoroAutoStart => 'अग्रिमखण्डं स्वयमेवारभताम्';

  @override
  String get trackingPomodoroAutoStartDetail =>
      'निष्क्रिये सति प्रत्येकं खण्डं भवतः स्पर्शं प्रतीक्षते।';

  @override
  String get trackingPomodoroNote =>
      'सूचनाध्वनिः केवलम् अभियोगोद्घाटने श्रूयते। इदमभियोगं बाह्याधिसूचनाः न प्रेषयति।';

  @override
  String trackingMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count निमेषाः',
      one: '1 निमेषः',
    );
    return '$_temp0';
  }

  @override
  String trackingBlocks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कार्यखण्डाः',
      one: '1 कार्यखण्डः',
    );
    return '$_temp0';
  }

  @override
  String get trackingBlockWork => 'ध्यानम्';

  @override
  String get trackingBlockShortBreak => 'लघुविरामः';

  @override
  String get trackingBlockLongBreak => 'दीर्घविरामः';

  @override
  String get trackingBlockDone => 'खण्डः समाप्तः';

  @override
  String get trackingStartNextBlock => 'अग्रिमखण्डम् आरभ्यताम्';

  @override
  String get trackingTimeDisplay => 'समयप्रदर्शनम्';

  @override
  String get trackingTimeDisplaySubtitle =>
      'समीपीकरणम्, रूपम्, हस्तचालितपूर्वनिर्धारणा च';

  @override
  String get trackingRounding => 'विवरणेषु समीपीकरणम्';

  @override
  String get trackingRoundingDetail =>
      'केवलं प्रदर्शनं परिवर्तते। रक्षितः समयः न विक्रियते।';

  @override
  String get trackingRoundingOff => 'यथार्थम्';

  @override
  String get trackingRounding1m => 'समीपस्थनिमेषः';

  @override
  String get trackingRounding5m => 'समीपस्थाः ५ निमेषाः';

  @override
  String get trackingRounding15m => 'समीपस्थाः १५ निमेषाः';

  @override
  String get trackingFormat => 'समयलेखनरूपम्';

  @override
  String get trackingFormatHhmmss => 'घण्टाः, निमेषाः, क्षणाः';

  @override
  String get trackingFormatHhmm => 'घण्टाः निमेषाश्च';

  @override
  String get trackingFormatDecimal => 'दशमलवघण्टाः';

  @override
  String get trackingFormatNote => 'प्रवर्तमानः समयगणकः सदा क्षणान् दर्शयति।';

  @override
  String get trackingManualDefault => 'हस्तचालितखण्डावधिः';

  @override
  String get trackingManualDefaultDetail =>
      'आरम्भसमये चित सति समाप्तिसमयः स्वयमेव एतावत् पूर्यते।';

  @override
  String get trackingManual15m => '१५ निमेषाः';

  @override
  String get trackingManual30m => '३० निमेषाः';

  @override
  String get trackingManual1h => '१ घण्टा';

  @override
  String get trackingManual2h => '२ घण्टे';

  @override
  String get pauseTimer => 'समयगणनं स्थग्यताम्';

  @override
  String get resumeTimer => 'समयगणनं पुनरारभ्यताम्';

  @override
  String get timerPaused => 'स्थगितम्';

  @override
  String get settingsPermissionsSubtitle => 'अभियोगस्य सम्बद्धाः अनुमतयः';

  @override
  String get appearanceThemeModeSubtitle =>
      'दीप्तं, श्यामं, तन्त्रसिद्धं वा रूपं चिनोतु';

  @override
  String get appearanceTypography => 'अक्षरशैली परिमाणं च';

  @override
  String get appearanceTypographySubtitle => 'अक्षरकुटुम्बः अक्षरपरिमाणं च';

  @override
  String get appearanceAccentColor => 'प्रधानवर्णः';

  @override
  String get appearanceAccentColorSubtitle =>
      'पूर्वनिर्धारणाः, वर्णचक्रम्, पूर्वदृश्यं च';

  @override
  String get themeModeHelp => 'तन्त्रसिद्धं रूपम् उपकरणस्य श्यामक्रममनुसरति।';

  @override
  String get typographyFontLabel => 'अक्षरशैली';

  @override
  String get typographyTextSizeLabel => 'अक्षरपरिमाणम्';

  @override
  String get typographySampleLatin => 'The quick brown fox 0123';

  @override
  String get typographySampleMalayalam => 'മലയാളം സുന്ദരമാണ്';

  @override
  String get fontSystemDefault => 'तन्त्रसिद्धम्';

  @override
  String get fontManjari => 'Manjari';

  @override
  String get fontAnekMalayalam => 'Anek Malayalam';

  @override
  String get fontNotoSansMalayalam => 'Noto Sans Malayalam';

  @override
  String get textSizeSmall => 'लघु';

  @override
  String get textSizeDefault => 'तन्त्रसिद्धम्';

  @override
  String get textSizeLarge => 'बृहत्';

  @override
  String get textSizeLarger => 'अतिबृहत्';

  @override
  String get accentLivePreview => 'प्रत्यक्षपूर्वदृश्यम्';

  @override
  String get accentPresets => 'पूर्वनिर्धारणाः';

  @override
  String get accentCustomWheel => 'स्वेच्छावर्णचक्रम्';

  @override
  String get accentSampleText => 'मातृकापाठः';

  @override
  String get accentAppliesToLight => 'अयम् वर्णः दीप्तरूपे प्रयुज्यते।';

  @override
  String get accentAppliesToDark => 'अयम् वर्णः श्यामरूपे प्रयुज्यते।';

  @override
  String get accentResetLight => 'दीप्तरूपस्य वर्णं पुनःसज्जीकुरुत';

  @override
  String get accentResetDark => 'श्यामरूपस्य वर्णं पुनःसज्जीकुरुत';

  @override
  String get accentContrastNote =>
      'सुपठनार्थं पाठस्य वर्णान्तरं स्वयमेव साध्यते।';

  @override
  String get permissionsLabel => 'अनुमतयः';

  @override
  String get permissionsSummary =>
      'अस्य अभियोगस्य कृते काश्चन अनुमतयः अपेक्षिताः।';

  @override
  String get permissionsImplicit => 'अन्तर्निहिताः अनुमतयः';

  @override
  String get permissionsExplicit => 'स्पष्टाः अनुमतयः';

  @override
  String get permissionsStorageTitle => 'सङ्ग्रहः';

  @override
  String get permissionsStorageBody =>
      'स्थानीयप्रतिरक्षासञ्चिकानां रक्षणाय आनयनाय च।';

  @override
  String get permissionsFilePickerTitle => 'सञ्चिकाचयनम्';

  @override
  String get permissionsFilePickerBody =>
      'प्रतिरक्षासञ्चिकानां चयनाय प्रयुज्यते।';

  @override
  String get permissionsSystemClockTitle => 'तन्त्रघटी';

  @override
  String get permissionsSystemClockBody => 'सटीकसमयगणनार्थं प्रयुज्यते।';

  @override
  String get permissionsTextProcessingTitle => 'पाठसंसाधनम्';

  @override
  String get permissionsTextProcessingBody =>
      'यूनिकोड्-अक्षराणां मानकीकरणार्थम्।';

  @override
  String get aboutLabel => 'विषयपरिचयः';

  @override
  String get aboutHeadline => 'SreerajP ToDo — जालरहितं कार्यप्रबन्धनम्';

  @override
  String get aboutSummary =>
      'दैनिककार्याणां समयगणनस्य च वैयक्तिकम् असंयुक्तप्रथमम् अभियोगम्।';

  @override
  String get aboutLocalOnlyTitle => 'केवलं स्थानीयम्';

  @override
  String get aboutLocalOnlyBody =>
      'शून्यजालसम्पर्कः, शून्यदत्तांशसङ्ग्रहः, सर्वोऽपि दत्तांशः यन्त्रे एव तिष्ठति।';

  @override
  String get aboutBackupTitle => 'गुप्तीकृता प्रतिरक्षा';

  @override
  String get aboutBackupBody =>
      'AES-256 गुप्तीकरणेन सह प्रतिरक्षासञ्चिकानां रक्षणम्।';

  @override
  String get aboutUnicodeTitle => 'पूर्णयूनिकोड्-समर्थनम्';

  @override
  String get aboutUnicodeBody =>
      'समग्रः पाठः NFC-मानकीकृतः। मलयलभाषायाः संस्कृतस्य च लिपीनां निर्दोषं समर्थनम्।';

  @override
  String get aboutNavigationTitle => 'सरलसञ्चारः';

  @override
  String get aboutNavigationBody =>
      'दीर्घसूचिकासु शीघ्रगमनाय सुलभसञ्चारव्यवस्था।';

  @override
  String get aboutAuthor => 'रचयिता';

  @override
  String get aboutAuthorName => 'Sreeraj P';

  @override
  String get aboutAiAssisted => 'कृत्रिमबुद्धिसहायता';

  @override
  String get aboutAiModels => 'Anthropic Claude, Google Gemini';

  @override
  String get aboutBuildDate => 'निर्मितिदिनाङ्कः';

  @override
  String get aboutAppVersion => 'संस्करणम्';

  @override
  String get aboutBuildNumber => 'निर्मितिसङ्ख्या';

  @override
  String get aboutMadeWithLoveIn => 'भारते प्रेम्णा निर्मितम्';

  @override
  String madeWithLove(String heart) {
    return 'भारतात् $heart सह निर्मितम्';
  }

  @override
  String get madeWithLoveA11y => 'भारते प्रेम्णा निर्मितम्';

  @override
  String get aboutDetailAuthor => 'रचयिता';

  @override
  String get aboutDetailEmail => 'विद्युत्पत्रम्';

  @override
  String get aboutDetailLicense => 'अनुज्ञापत्रम्';

  @override
  String get aboutDetailAiUsed => 'प्रयुक्ता कृत्रिमबुद्धिः';

  @override
  String get aboutDetailIdeUsed => 'प्रयुक्तं विकाससाधनम्';

  @override
  String get statsDailyOverview => 'दैनिकविहङ्गावलोकनम्';

  @override
  String get statsPerItemOverview => 'कार्यविशेषविहङ्गावलोकनम्';

  @override
  String get statsChooseTask => 'कार्यं चिनोतु';

  @override
  String get statsLast7Days => 'विगत ७ दिनानि';

  @override
  String get statsLast30Days => 'विगत ३० दिनानि';

  @override
  String get statsAllTime => 'सर्वकालम्';

  @override
  String get statsCustomRange => 'स्वेच्छाकालखण्डम्';

  @override
  String get statsRefresh => 'नवीक्रियताम्';

  @override
  String get statsTotalTodos => 'कुलकार्याणि';

  @override
  String get statsTotal => 'कुलम्';

  @override
  String get statsDate => 'दिनाङ्कः';

  @override
  String get statsTitle => 'शीर्षकम्';

  @override
  String get statsAppearances => 'उपस्थितयः';

  @override
  String get statsAverageCompletedPerDay => 'दैनिकसमापितसरासरिः';

  @override
  String get statsAverageTimePerDay => 'दैनिकसमयसरासरिः';

  @override
  String get statsProductiveTime => 'उत्पादकसमयः';

  @override
  String get statsDroppedTime => 'त्यक्तसमयः';

  @override
  String get statsSearchHint => 'दत्तांशेऽन्विष्यताम्...';

  @override
  String get statsNoDailyStats => 'अस्मिन् दिने साङ्ख्यिकी नास्ति';

  @override
  String get statsNoPerItemStats => 'कार्याणां साङ्ख्यिकी नास्ति';

  @override
  String get statsSelectTaskToViewHistory => 'इतिवृत्तं द्रष्टुं कार्यं चिनोतु';

  @override
  String get statsNoHistoryForTitle =>
      'अस्य कार्यस्य कृते समयखण्डाः न पञ्जीकृताः।';

  @override
  String get statsMinutes => 'निमेषाः';

  @override
  String get statsSelectStartDate => 'आरम्भदिनाङ्कं चिनोतु';

  @override
  String get statsSelectEndDate => 'समाप्तिदिनाङ्कं चिनोतु';

  @override
  String get statsShowHistory => 'इतिवृत्तं दर्शयतु';

  @override
  String statsPageOf(int currentPage, int totalPages) {
    return '$totalPages पृष्ठेषु $currentPage पृष्ठम्';
  }

  @override
  String statsHistoryFor(String title) {
    return '$title कृते इतिवृत्तम्';
  }

  @override
  String get errorDayLocked =>
      'इदं दिनं कीलितम्। व्यतीतानि दिनानि अपरिवर्तनीयानि।';

  @override
  String get errorCompletedLocked =>
      'समापिते कार्ये नूतनसमयखण्डाः न योज्यन्ते।';

  @override
  String get errorDuplicateTitle =>
      'अस्मिन् दिने अनेन नाम्ना कार्यं पूर्वमेव विद्यते।';

  @override
  String get errorSegmentAlreadyRunning =>
      'अस्य कार्यस्य कृते एकः समयखण्डः पूर्वमेव प्रवर्तते।';

  @override
  String get errorTodoNotFound => 'कार्यं न प्राप्तम्।';

  @override
  String get errorBackupVersionTooNew => 'इयं प्रतिरक्षा नूतनसंस्करणस्य अस्ति।';

  @override
  String get errorBackupCorrupted => 'प्रतिरक्षासञ्चिका विकृता अस्ति।';

  @override
  String get errorPortTargetMustBeFuture =>
      'स्थानान्तरणाय लक्ष्यदिनाङ्कः भविष्यत्कालीनः भवेत्।';

  @override
  String get errorGeneric => 'कश्चन दोषः जातः। पुनः प्रयत्यताम्।';

  @override
  String get errorRetryableGeneric => 'दोषः जातः। पुनः प्रयत्यताम्।';

  @override
  String get subTasks => 'उपकार्याणि';

  @override
  String get addSubTask => 'उपकार्यं योज्यताम्';

  @override
  String get blockedBy => 'अवरुद्धम्';

  @override
  String get prerequisiteTasks => 'पूर्वापेक्षितकार्याणि';

  @override
  String get blockedWarning =>
      'पूर्वापेक्षितकार्याणां समापनात् पूर्वम् इदं कार्यं न समापनीयम्।';

  @override
  String get morningIntention => 'प्रातःसङ्कल्पः';

  @override
  String get eveningReflection => 'सायंविमर्शः';

  @override
  String get eveningReflectionTitle => 'सायन्तनो विमर्शः';

  @override
  String get reflectionSummaryTitle => 'विमर्शसारांशः';

  @override
  String get completedTime => 'समापितसमयः';

  @override
  String get droppedTime => 'त्यक्तसमयः';

  @override
  String get completionRatio => 'समाप्तिप्रतिशतम्';

  @override
  String get reflectionNoteHint => 'अद्यतनदिनस्य विषये काचन टिप्पणी...';

  @override
  String get reflectionSaved => 'विमर्शः रक्षितः';

  @override
  String get cycleIntention => 'सङ्कल्पं परिवर्तयतु';

  @override
  String get startReflection => 'विमर्शम् आरभ्यताम्';

  @override
  String get mindfulFocusRules => 'सचेतनध्याननियमाः';

  @override
  String get defaultIntention1 =>
      'अद्य मुख्यकार्ये पूर्णमनोयोगेन प्रवर्तिष्ये।';

  @override
  String get defaultIntention2 =>
      'विघ्नान् दूरीकृत्य शान्तचित्तेन कार्यं सम्पादयिष्यामि।';

  @override
  String get defaultIntention3 =>
      'क्रमबद्धतया प्रत्येकं कार्यं समये समापयिष्यामि।';

  @override
  String get defaultIntention4 => 'धैर्येण श्रद्धया च कार्येषु प्रवर्तिष्ये।';

  @override
  String get defaultIntention5 =>
      'अग्रिमगमनात् पूर्वं प्रत्येकं खण्डं पूर्णसावधानेन समापयिष्यामि।';

  @override
  String get dataHandoffTitle => 'दत्तांशहस्तान्तरणम् (JSON & MD)';

  @override
  String get actionChange => 'परिवर्त्यताम्';

  @override
  String get dataHandoffHeader => 'JSON & Markdown दत्तांशहस्तान्तरणम्';

  @override
  String get dataHandoffSubtitle =>
      'कार्यसूचिकाः, उपकार्याणि, समयविवरणं च सर्वथा जालरहितम् आनाय्यतां निर्याप्यतां च।';

  @override
  String get exportJsonLabel => 'JSON दत्तांशसञ्चिकां निर्यापयतु';

  @override
  String get exportJsonDesc =>
      'कार्याणि, उपकार्याणि, पुनरावृत्तिनियमान्, समयखण्डांश्च JSON सञ्चिकारूपेण रक्षति।';

  @override
  String get exportMarkdownLabel => 'Markdown कार्यसूचीं निर्यापयतु';

  @override
  String get exportMarkdownDesc =>
      'स्वच्छां Markdown सूचीं (- [ ] / - [x]) समयसारणीं च जनयति।';

  @override
  String get importFileLabel => 'JSON / Markdown सञ्चिकाम् आनाययतु';

  @override
  String get importFileDesc =>
      'उपकरणसञ्चयात् .json .md वा सञ्चिकां चित्वा कार्येषु योजयतु।';

  @override
  String get pasteMarkdownLabel => 'Markdown पाठं लेपयतु';

  @override
  String get pasteMarkdownDesc =>
      '- [ ] तथा - [x] युक्तं Markdown पाठं प्रत्यक्षं लेपयित्वा आनाययतु।';

  @override
  String get targetDateLabel => 'हस्तान्तरणाय लक्ष्यदिनाङ्कः';

  @override
  String get markdownImportTitle => 'Markdown सूचीपाठं लेपयतु';

  @override
  String get parseMarkdownPreview => 'लब्धकार्याणां पूर्वदृश्यम्';

  @override
  String get importSuccessMsg => 'कार्याणि साफल्येन आनीतानि।';

  @override
  String get exportSuccessMsg => 'निर्यातः सञ्चिकायां साफल्येन रक्षितः।';

  @override
  String get wifiSyncTitle => 'स्थानीय P2P Wi-Fi समकालनम्';

  @override
  String get airQrShareTitle => 'AirQR प्रसारधारा';

  @override
  String get airQrScanTitle => 'AirQR छायाग्राही';

  @override
  String get moreOptions => 'अधिकविकल्पाः';

  @override
  String get settingsTaskDefaults => 'कार्यपूर्वनिर्धारणाः';

  @override
  String get settingsTaskDefaultsSubtitle =>
      'नूतनकार्यमूल्यानि, दिनसूचीक्रमः, स्थिरीकरणानि, अग्रेप्रेषणं च';

  @override
  String get defaultsNewTask => 'नूतनं कार्यम्';

  @override
  String get defaultsNewTaskSubtitle =>
      'नूतनकार्यस्य स्थितिः, प्राथमिकता, लक्ष्यसमयश्च';

  @override
  String get defaultsDayList => 'दिनसूची';

  @override
  String get defaultsDayListSubtitle => 'क्रमः, समापितकार्याणां प्रदर्शनं च';

  @override
  String get defaultsTaskActions => 'कार्यक्रियाः';

  @override
  String get defaultsTaskActionsSubtitle =>
      'स्थिरीकरणानि, नूतनदिने कार्याणाम् अग्रेप्रेषणं च';

  @override
  String get defaultsAutocomplete => 'स्वयम्पूर्णता';

  @override
  String get defaultsAutocompleteSubtitle => 'लेखनकाले शीर्षकप्रस्तावाः';

  @override
  String get defaultsStatusTitle => 'पूर्वनिर्धारिता स्थितिः';

  @override
  String get defaultsStatusSubtitle => 'नूतनकार्यस्य प्रारम्भावस्था।';

  @override
  String get defaultsStatusPendingDetail =>
      'सामान्यविकल्पः। आरम्भात् पूर्वं कार्यं प्रतीक्षते।';

  @override
  String get defaultsStatusWorkingDetail =>
      'कार्यं प्रवर्तमानत्वेन उद्घाट्यते। समयगणकम् नारभ्यते।';

  @override
  String get defaultsPriorityTitle => 'पूर्वनिर्धारिता प्राथमिकता';

  @override
  String get defaultsPrioritySubtitle =>
      'नूतनकार्यस्य प्रारम्भावस्थायाः प्राथमिकता।';

  @override
  String get defaultsTargetTitle => 'पूर्वनिर्धारितः लक्ष्यसमयः';

  @override
  String get defaultsTargetSubtitle =>
      'नूतनकार्यस्य अपेक्षितः समयः। कार्यविशेषे अयं परिवर्तयितुं शक्यते।';

  @override
  String get defaultsTargetNone => 'लक्ष्यं नास्ति';

  @override
  String get priorityLow => 'मन्दा';

  @override
  String get priorityNormal => 'साधारणी';

  @override
  String get priorityHigh => 'उच्चा';

  @override
  String get priorityUrgent => 'अत्यावश्यकी';

  @override
  String get priorityLabel => 'प्राथमिकता';

  @override
  String get targetTimeLabel => 'लक्ष्यसमयः';

  @override
  String get targetTimeHint => 'लक्ष्यसमयः (घण्टाः:निमेषाः)';

  @override
  String get targetHoursLabel => 'घण्टाः';

  @override
  String get targetMinutesLabel => 'निमेषाः';

  @override
  String get targetHoursRangeError => '०–२३';

  @override
  String get targetMinutesRangeError => '०–५९';

  @override
  String targetProgressLabel(String target, String tracked) {
    return '$tracked / $target';
  }

  @override
  String targetOverBy(String amount) {
    return '$amount अधिकम्';
  }

  @override
  String get defaultsSortTitle => 'पूर्वनिर्धारितः क्रमः';

  @override
  String get defaultsSortSubtitle => 'दिनसूची येन क्रमेण उद्घाट्यते।';

  @override
  String get defaultsRememberSort => 'अन्तिमचितक्रमं स्मरतु';

  @override
  String get defaultsRememberSortDetail =>
      'दिनसूचौ क्रमपरिवर्तने तत् पूर्वनिर्धारितरूपेणापि रक्ष्यते।';

  @override
  String get defaultsShowCompleted => 'समापितानि कार्याणि दर्शयतु';

  @override
  String get defaultsShowCompletedDetail =>
      'समापितकार्याणां निगूहनार्थम् एतत् पिधत्त।';

  @override
  String get defaultsShowDropped => 'त्यक्तानि कार्याणि दर्शयतु';

  @override
  String get defaultsShowDroppedDetail =>
      'त्यक्तकार्याणां निगूहनार्थम् एतत् पिधत्त।';

  @override
  String get defaultsSinkFinished => 'समापितानि कार्याणि अधः नयतु';

  @override
  String get defaultsSinkFinishedDetail =>
      'समापितानि त्यक्तानि च कार्याणि सूचीपुच्छे स्थाप्यन्ते।';

  @override
  String hiddenTasksCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString निगूढानि कार्याणि',
      one: '1 निगूढं कार्यम्',
    );
    return '$_temp0';
  }

  @override
  String get showHiddenTasks => 'निगूढकार्याणि दर्शयतु';

  @override
  String get defaultsConfirmComplete => 'समापने स्थिरीकरणं याचताम्';

  @override
  String get defaultsConfirmCompleteDetail =>
      'कार्यसमापनात् पूर्वं स्थिरीकरणं पृच्छ्यते।';

  @override
  String get defaultsConfirmDrop => 'त्यागकाले स्थिरीकरणं याचताम्';

  @override
  String get defaultsConfirmDropDetail =>
      'कार्यत्यागात् पूर्वं स्थिरीकरणसन्दूषः दृश्यते।';

  @override
  String get confirmCompleteTitle => 'कार्यं समाप्यतां वा?';

  @override
  String get confirmCompleteBody =>
      'इदं कार्यं समाप्य प्रवर्तमानं समयगणनं विरंस्यति।';

  @override
  String get defaultsAutoCarryOver => 'अवशिष्टानि कार्याणि स्वयमेवाग्रे नयतु';

  @override
  String get defaultsAutoCarryOverDetail =>
      'नूतनदिनोद्घाटने पूर्वतनदिनस्य अवशिष्टानि कार्याणि स्वयमेव अद्य आनीयन्ते।';

  @override
  String autoCarryOverDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कार्याणि अग्रे आनीतानि',
      one: '1 कार्यम् अग्रे आनीतम्',
    );
    return '$_temp0';
  }

  @override
  String get defaultsCarryOver => 'कार्याणाम् अग्रेप्रेषणम्';

  @override
  String get defaultsCarryOverDetail =>
      'असमापितकार्याणि नूतने दिने स्वयमेव आनीयन्ताम्।';

  @override
  String get defaultsCarryOverLookBackTitle => 'कियन्ति दिनानि अवलोकनीयानि';

  @override
  String get defaultsCarryOverPreviousDay => 'केवलं पूर्वतनदिनम्';

  @override
  String get defaultsCarryOverLastSevenDays => 'विगत ७ दिनानि';

  @override
  String get carryOverTitle => 'असमापितानि कार्याणि';

  @override
  String get carryOverBody =>
      'पूर्वेभ्यो दिनेभ्यः असमापितानि कार्याणि अद्यतनदिने आनेतव्यानि वा?';

  @override
  String get carryOverAction => 'अद्य आनयतु';

  @override
  String get carryOverNotNow => 'अधुना मास्तु';

  @override
  String get carryOverNeverAsk => 'पुनः मा पृच्छतु';

  @override
  String get carryOverSelectAll => 'सर्वाणि चीयन्ताम्';

  @override
  String get carryOverClearAll => 'सर्वाणि मुच्यन्ताम्';

  @override
  String carryOverDone(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString कार्याणि अग्रे प्रेषितानि',
      one: '1 कार्यम् अग्रे प्रेषितम्',
    );
    return '$_temp0';
  }

  @override
  String carryOverSkipped(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString कार्याणि उपेक्षितानि, अद्य पूर्वमेव सन्ति',
      one: '1 कार्यम् उपेक्षितम्, अद्य पूर्वमेव विद्यते',
    );
    return '$_temp0';
  }

  @override
  String get defaultsAutocompleteEnabled => 'शीर्षकप्रस्तावाः';

  @override
  String get defaultsAutocompleteEnabledDetail =>
      'नूतनकार्यलेखनकाले पूर्वप्रयुक्तानि शीर्षकानि सूच्यन्ते।';

  @override
  String get defaultsSuggestionCountTitle => 'शीर्षकप्रस्तावानां सङ्ख्या';

  @override
  String suggestionCountValue(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString प्रस्तावाः';
  }

  @override
  String get sortPriorityHigh => 'प्राथमिकता (उच्चा प्रथमा)';

  @override
  String get settingsDateTime => 'दिनाङ्कः समयश्च';

  @override
  String get settingsDateTimeSubtitle =>
      'घटीरूपम्, दिनाङ्करूपम्, सप्ताहप्रारम्भश्च';

  @override
  String get dateTimeWeekStart => 'सप्ताहस्य प्रथमदिनम्';

  @override
  String get dateTimeWeekStartSubtitle => 'दिनदर्शिकायां सप्ताहस्य आरम्भः';

  @override
  String get dateTimeClock => 'घटीरूपम्';

  @override
  String get dateTimeClockSubtitle => '१२ वा २४ घण्टारूपम्';

  @override
  String get dateTimeDateFormat => 'दिनाङ्करूपम्';

  @override
  String get dateTimeDateFormatSubtitle => 'दिनाङ्कलेखनक्रमः';

  @override
  String get dateTimeDayStart => 'दिनप्रारम्भसमयः';

  @override
  String get dateTimeDayStartSubtitle => 'नूतनं दिनं कदा आरभते';

  @override
  String get dateTimeWorkingDays => 'कार्यदिनानि';

  @override
  String get dateTimeWorkingDaysSubtitle =>
      'साङ्ख्यिकीगणनायै प्रयुक्तानि दिनानि';

  @override
  String get weekStartTitle => 'सप्ताहस्य प्रथमदिनम्';

  @override
  String get weekStartSubtitle => 'दिनदर्शिकासु गणनासु च प्रयुज्यते।';

  @override
  String get weekStartSystem => 'तन्त्रसिद्धम्';

  @override
  String get clockFormatTitle => 'घटीरूपम्';

  @override
  String get clockFormatSubtitle => 'अभियोगे सर्वत्र समयः कथं दृश्यते।';

  @override
  String get clockFormatSystem => 'तन्त्रसिद्धम्';

  @override
  String get clockFormat12 => '१२-घण्टारूपम्';

  @override
  String get clockFormat24 => '२४-घण्टारूपम्';

  @override
  String get dateFormatTitle => 'दिनाङ्करूपम्';

  @override
  String get dateFormatSubtitle => 'अभियोगे सर्वत्र दिनाङ्कप्रदर्शनक्रमः।';

  @override
  String get dateFormatSystem => 'तन्त्रसिद्धम् (दीर्घम्)';

  @override
  String get dateFormatSystemShort => 'तन्त्रसिद्धम् (ह्रस्वम्)';

  @override
  String get dateFormatDayMonthYear => 'दिनम्/मासः/वर्षम्';

  @override
  String get dateFormatMonthDayYear => 'मासः/दिनम्/वर्षम्';

  @override
  String get dateFormatDayMonthNameYear => 'दिनम् मासनाम वर्षम्';

  @override
  String get dateFormatIso => 'वर्षम्-मासः-दिनम्';

  @override
  String get dayStartTitle => 'दिनप्रारम्भसमयः';

  @override
  String get dayStartSubtitle =>
      'मध्यरात्रेः परं कार्यं कुर्वताम् एतत् उपकरोति।';

  @override
  String get dayStartMidnight => 'मध्यरात्रौ (००:००)';

  @override
  String get dayStartExplainTitle => 'दिनप्रारम्भस्य व्याख्या';

  @override
  String get dayStartExplainBody =>
      'मध्यरात्रेः परं कार्यं कुर्वन्तः जनाः दिनप्रारम्भसमयं प्रातः ४ वा ५ वादने स्थापयितुं शक्नुवन्ति।';

  @override
  String dayStartCurrentDay(String date) {
    return 'अधुना अभियोगः अद्यतनत्वेन $date मन्यते।';
  }

  @override
  String get workingDaysTitle => 'कार्यदिनानि';

  @override
  String get workingDaysSubtitle =>
      'कार्यगणनायां लक्ष्येषु च एतानि दिनानि गण्यन्ते।';

  @override
  String get workingDaysReset => 'कार्यदिनानि पुनःसज्जीकुरुत';

  @override
  String get workingDaysNoneWarning =>
      'न्यूनातिन्यूनम् एकं कार्यदिनं चितं भवेत्।';

  @override
  String get settingsSecurity => 'सुरक्षा';

  @override
  String get settingsSecuritySubtitle =>
      'अभियोगकीलम्, सुरक्षासंकेतः, जैविकसुरक्षा च';

  @override
  String get securityAppLock => 'अभियोगकीलम्';

  @override
  String get securityAppLockSubtitle => 'अभियोगोद्घाटनाय सुरक्षासंकेतं याचताम्';

  @override
  String get securityAutoLock => 'स्वचालितकीलम्';

  @override
  String get securityAutoLockSubtitle => 'अभियोगत्यागे स्वयमेव कीलनम्';

  @override
  String get securityDatabaseKey => 'दत्तांशकुञ्चिका';

  @override
  String get securityDatabaseKeySubtitle =>
      'दत्तांशगुप्तीकरणकुञ्चिकायाः चक्रभ्रमणम्';

  @override
  String get securityScreenPrivacy => 'पटलगोपनीयता';

  @override
  String get securitySecureScreen => 'पटलच्छायाचित्रं निवारयतु';

  @override
  String get securitySecureScreenDetail =>
      'सद्यःप्रयुक्तसूचौ पटलस्य छायाचित्रं न दर्शयति।';

  @override
  String get securitySecureScreenUnsupported =>
      'केवलाण्ड्राय्ड्-यन्त्रे समर्थितम्।';

  @override
  String get securityNotificationsNote =>
      'इदमभियोगं जालरहितं वर्तते, बाह्याधिसूचनाः न प्रेषयति।';

  @override
  String get appLockModeTitle => 'कीलनप्रकारः';

  @override
  String get appLockModeSubtitle => 'संकेतः, जैविकसुरक्षा, वा निष्क्रियमिति';

  @override
  String get appLockOff => 'निष्क्रियम्';

  @override
  String get appLockPin => 'सुरक्षासंकेतः';

  @override
  String get appLockPassword => 'सुरक्षासंकेतः (PIN)';

  @override
  String get appLockDeviceCredential => 'यन्त्रसुरक्षा (अङ्गुलीमुद्रा/संकेतः)';

  @override
  String get appLockDeviceCredentialDetail =>
      'यन्त्रस्य मुख्यकीलनं प्रयुङ्क्तु।';

  @override
  String get appLockDeviceUnavailable => 'यन्त्रे जैविकसुरक्षा न सज्जिता।';

  @override
  String get appLockSetPin => 'सुरक्षासंकेतं योजयतु';

  @override
  String get appLockSetPassword => 'गुप्तपदं योजयतु';

  @override
  String get appLockNewSecret => 'नूतनसंकेतः';

  @override
  String get appLockConfirmSecret => 'संकेतं स्थिरीकुरुत';

  @override
  String get appLockChange => 'परिवर्त्यताम्';

  @override
  String get appLockSaved => 'सुरक्षाविन्यासः रक्षितः';

  @override
  String get appLockRemoved => 'अभियोगकीलम् अपनीतम्';

  @override
  String get appLockWarningTitle => 'सावधानता';

  @override
  String get appLockWarningBody =>
      'यदि सुरक्षासंकेतं विस्मरति तर्हि अभियोगस्य पुनर्प्रतिष्ठापनम् एव एकः मार्गः।';

  @override
  String get appLockErrorEmpty => 'संकेतः रिक्तः भवितुं नार्हति';

  @override
  String get appLockErrorNotDigits => 'केवलं संख्यङ्काः एव प्रयोक्तव्याः';

  @override
  String get appLockErrorPinTooShort =>
      'संकेतः अतिलघुः अस्ति (न्यूनातिन्यूनं ४ अङ्काः)';

  @override
  String get appLockErrorPinTooLong =>
      'संकेतः अतिदीर्घः अस्ति (अधिकतमं ६ अङ्काः)';

  @override
  String get appLockErrorPasswordTooShort =>
      'गुप्तपदे न्यूनातिन्यूनं ६ अक्षराणि भवेयुः';

  @override
  String get appLockErrorMismatch => 'संकेते न समेते';

  @override
  String get autoLockTitle => 'स्वचालितकीलनम्';

  @override
  String get autoLockSubtitle => 'कियता कालेन कीलनं भवेत्';

  @override
  String get autoLockImmediately => 'सद्य एव';

  @override
  String get autoLock30Seconds => '३० क्षणाः';

  @override
  String get autoLock1Minute => '१ निमेषः';

  @override
  String get autoLock5Minutes => '५ निमेषाः';

  @override
  String get autoLock15Minutes => '१५ निमेषाः';

  @override
  String get autoLockNever => 'कदापि न';

  @override
  String get autoLockNeedsLock => 'प्रथमम् अभियोगकीलम् उद्घाट्यताम्।';

  @override
  String get databaseKeyTitle => 'दत्तांशकुञ्चिका';

  @override
  String get databaseKeyBody =>
      'SQLite दत्तांशः यन्त्रोत्पन्नकुञ्चिकया AES-256 रूपेण गुप्तीकृतः।';

  @override
  String get databaseKeyBackupFirst =>
      'कुञ्चिकापरिवर्तनात् पूर्वं प्रतिरक्षां स्वीकुरुत।';

  @override
  String get databaseKeyOldBackups =>
      'पूर्वनिर्मिताः प्रतिरक्षाः अप्रभाविताः तिष्ठन्ति।';

  @override
  String get databaseKeyRotate => 'कुञ्चिकां परिवर्तयतु';

  @override
  String get databaseKeyConfirmTitle => 'कुञ्चिकापरिवर्तनस्य स्थिरीकरणम्';

  @override
  String get databaseKeyConfirmBody =>
      'समग्रोऽपि दत्तांशः नूतनकुञ्चिकया पुनर्गुप्तीकरिष्यते।';

  @override
  String get databaseKeyWorking => 'कुञ्चिका परिवर्त्यते...';

  @override
  String get databaseKeyDone => 'दत्तांशकुञ्चिका साफल्येन परिवर्तिता';

  @override
  String get databaseKeyFailed => 'कुञ्चिकापरिवर्तनं विफलम्';

  @override
  String get lockScreenTitle => 'SreerajP ToDo कीलितम्';

  @override
  String get lockScreenEnterPin => 'सुरक्षासंकेतं लिखतु';

  @override
  String get lockScreenEnterPassword => 'गुप्तपदं लिखतु';

  @override
  String get lockScreenUnlock => 'उद्घाट्यताम्';

  @override
  String get lockScreenWrong => 'अशुद्धः संकेतः। पुनः प्रयत्यताम्।';

  @override
  String lockScreenWait(int seconds) {
    return 'अत्यधिकाः यत्नाः। $seconds क्षणान् प्रतीक्षताम्।';
  }

  @override
  String get lockScreenUseDeviceLock => 'यन्त्रसुरक्षां प्रयुङ्क्तु';

  @override
  String get lockScreenDevicePrompt => 'उद्घाटनाय यन्त्रसुरक्षां प्रयुङ्क्तु';

  @override
  String get lockScreenDeviceDescription =>
      'अङ्गुलीमुद्रया वा यन्त्रसंकेतेन उद्घाट्यताम्';

  @override
  String get lockScreenDeviceFailed => 'यन्त्रप्रमाणीकरणं विफलम्';

  @override
  String get focusTitle => 'ध्यानक्रमः';

  @override
  String get focusOpen => 'उद्घाट्यताम्';

  @override
  String get focusLeave => 'निर्गम्यताम्';

  @override
  String get focusRunningNow => 'अधुना ध्यानं प्रवर्तते';

  @override
  String get focusTotalTracked => 'कुलं गणितम्';

  @override
  String get focusSteps => 'पदानि';

  @override
  String get focusNoSteps => 'पदानि न सन्ति';

  @override
  String get focusNotRunning => 'ध्यानं न प्रवर्तते';

  @override
  String focusNextNudge(String time) {
    return 'अग्रिमस्मारणं $time परम्';
  }

  @override
  String get focusNudgesOff => 'स्मारणानि पिहितानि';

  @override
  String get trackingFocusMode => 'ध्यानक्रमः';

  @override
  String get trackingFocusModeSubtitle => 'पूर्णमनोयोगेन कार्यसम्पादनम्';

  @override
  String get trackingFocusPulse => 'ध्यानस्पन्दः';

  @override
  String get trackingFocusPulseOff => 'पिहितम्';

  @override
  String get trackingFocusPulseVibration => 'कम्पनम्';

  @override
  String get trackingFocusPulseSound => 'ध्वनिः';

  @override
  String get trackingFocusPulseBoth => 'उभयम्';

  @override
  String get trackingFocusPulseEvery => 'प्रत्येकम्';

  @override
  String get trackingFocusView => 'ध्यानदृश्यम्';

  @override
  String get trackingFocusImmersive => 'निमग्नदृश्यम्';

  @override
  String get trackingFocusImmersiveDetail =>
      'पटलस्य सर्वाणि विक्षेपकवस्तूनि निगूह्यन्ते।';

  @override
  String get trackingFocusNote => 'ध्यानक्रमे एकाग्रता वर्धते।';

  @override
  String get trackingFocusPomodoroNote =>
      'पोमोडोरो-पद्धत्या सह ध्यानक्रमः उत्तमं प्रवर्तते।';

  @override
  String get voiceSheetTitle => 'वाणीनिर्देशः';

  @override
  String get voiceSheetOfflineNote => 'सर्वथा जालरहितं यन्त्रे एव संसाध्यते।';

  @override
  String get voiceSheetFieldLabel => 'श्रुतः पाठः';

  @override
  String get voiceSheetExample => 'यथा: \'नूतनं कार्यम् अध्ययन्\'';

  @override
  String get voiceLanguageEnglish => 'English';

  @override
  String get voiceLanguageMalayalam => 'മലയാളം';

  @override
  String get voiceTapToSpeak => 'वक्तुं स्पृशतु';

  @override
  String get voiceListening => 'श्रूयते...';

  @override
  String get voiceClear => 'मार्जयतु';

  @override
  String get voiceUnderstoodHeading => 'अवगतः निर्देशः';

  @override
  String get voiceNoTitle => 'शीर्षकं न प्राप्तम्';

  @override
  String get voiceCreateTask => 'कार्यं सृज्यताम्';

  @override
  String get voiceDescriptionHeading => 'वर्णनम्';

  @override
  String get voiceEditDetails => 'विवरणं सम्पाद्यताम्';

  @override
  String get voiceDuplicateTitle => 'इदं शीर्षकं पूर्वमेव विद्यते';

  @override
  String get voiceDictateTooltip => 'वाणीनिर्देशाय स्पृशतु';

  @override
  String get voiceDateMovedToToday => 'अद्यतनदिने स्थानान्तरितम्';

  @override
  String get voiceErrorPermission => 'ध्वनिमुद्रणानुमतिः नास्ति';

  @override
  String get voiceErrorNoMatch => 'किमपि न श्रुतम्। पुनः प्रयत्यताम्।';

  @override
  String get voiceErrorNoOfflineLanguage => 'असंयुक्तभाषापुस्तकालयः न प्राप्तः';

  @override
  String get voiceErrorBusy => 'ध्वनिग्राहकः व्यग्रः अस्ति';

  @override
  String get voiceErrorUnknown => 'अज्ञातो वाणीदोषः';

  @override
  String get voiceUnavailableDevice => 'यन्त्रे वाणीसेवा नोपलभ्यते।';

  @override
  String get voiceUnavailableNoRecogniser => 'वाणीप्रत्यभिज्ञापकः न प्राप्तः।';

  @override
  String get voiceUnavailableNoOffline => 'जालरहितवाणीसेवा नोपलभ्यते';

  @override
  String get voiceUnavailableNoPermission =>
      'अनुमतिं विना वाणीसेवा न प्रवर्तते';

  @override
  String get voiceOpenTooltip => 'वाणीनिर्देशफलकम् उद्घाट्यताम्';

  @override
  String get voiceInputSetting => 'वाणीप्रवेशः';

  @override
  String get voiceInputSettingDetail => 'शीघ्रकार्ययोजनाय वाणी प्रयुज्यताम्';

  @override
  String get voiceInputTypingNote =>
      'लेखनस्थाने साक्षात् वाणीं प्रयोक्तुं शक्यते।';

  @override
  String get permissionsCameraTitle => 'छायाग्राही';

  @override
  String get permissionsCameraBody =>
      'AirQR समकालनाय तथा पाठप्रत्यभिज्ञायै (OCR) प्रयुज्यते।';

  @override
  String get permissionsMicrophoneTitle => 'ध्वनिग्राहकः';

  @override
  String get permissionsMicrophoneBody => 'वाणीनिर्देशानां ग्रहणे प्रयुज्यते।';

  @override
  String get permissionsExplicitNote =>
      'एताः अनुमतयः उपयोक्तृसम्मत्या एव प्रयुज्यन्ते।';

  @override
  String voiceTimeNote(String time) {
    return 'समयः $time';
  }

  @override
  String get settingsRitual => 'दैनिकानुष्ठानम्';

  @override
  String get settingsRitualSubtitle =>
      'सङ्कल्पः, श्वासप्रणायामः, ज्ञानपत्राणि च';

  @override
  String get ritualTitle => 'दैनिकानुष्ठानम्';

  @override
  String get ritualEnabled => 'दैनिकानुष्ठानं प्रयुज्यताम्';

  @override
  String get ritualEnabledDetail =>
      'प्रतिदिनं मनः शान्तं कर्तुम् अनुष्ठानम् उद्घाट्यताम्।';

  @override
  String get ritualOpenOnLaunch => 'अभियोगोद्घाटने दर्शयतु';

  @override
  String get ritualOpenOnLaunchDetail =>
      'प्रतिदिनं प्रथमवारम् उद्घाटने अनुष्ठानं पुरतो भवति।';

  @override
  String get ritualBreathSection => 'प्राणायामः';

  @override
  String get ritualBreathTechnique => 'श्वासविधिः';

  @override
  String get ritualBreathBox => 'चतुरस्रप्राणायामः (४-४-४-४)';

  @override
  String get ritualBreathRelaxing => 'विश्रामप्राणायामः (४-७-८)';

  @override
  String get ritualBreathCalm => 'शान्तिप्राणायामः';

  @override
  String get ritualBreathCyclesLabel => 'श्वासचक्राणि';

  @override
  String ritualBreathCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString श्वासाः',
      one: '१ श्वासः',
    );
    return '$_temp0';
  }

  @override
  String get ritualHaptic => 'कम्पनस्पर्शः';

  @override
  String get ritualHapticDetail => 'श्वासपरिवर्तने सूक्ष्मं कम्पनम्।';

  @override
  String get ritualStepsSection => 'अनुष्ठानपदानि';

  @override
  String get ritualCardStepSwitch => 'एकं चिन्तनपत्रं दर्शयतु';

  @override
  String get ritualCardStepDetail =>
      'अन्तिमवारदर्शनक्रमेण ज्ञानकोशात् एकमेकं पत्रम्।';

  @override
  String get ritualSettleStepSwitch => 'शान्तिक्रमः';

  @override
  String get ritualSettleStepDetail => 'कार्याणां पुनरीक्षणं ध्यानं च।';

  @override
  String get ritualEveningSection => 'सायन्तनो विमर्शः';

  @override
  String get ritualEveningClose => 'सायन्तने स्मरणम्';

  @override
  String get ritualEveningCloseDetail =>
      'दिनावसाने कृतकार्याणां कृतज्ञतायाश्च विमर्शः।';

  @override
  String get ritualEveningFrom => 'सायन्तनसमयः';

  @override
  String get ritualDeckSection => 'ज्ञानपत्राणि';

  @override
  String get ritualBrowseDeck => 'पत्रावलीं पश्यतु';

  @override
  String get ritualBrowseDeckDetail => 'दैनिकचिन्तनार्थं सूक्तिपत्राणि।';

  @override
  String get ritualResetReviews => 'पुनरावलोकनं पुनःसज्जीकुरुत';

  @override
  String get ritualResetReviewsDetail =>
      'सर्वपत्राणां प्रगतिः आरम्भावस्थां नेष्यते।';

  @override
  String get ritualResetConfirmTitle => 'पुनःसज्जीकरणम्';

  @override
  String get ritualResetConfirmBody =>
      'किं ज्ञानपत्राणां प्रगतिः सर्वथा पुनःसज्जीकर्तव्या?';

  @override
  String get ritualResetDone => 'ज्ञानपत्राणि पुनःसज्जितानि।';

  @override
  String get ritualRunNow => 'इदानीम् आरभ्यताम्';

  @override
  String get ritualStepBreathe => 'प्राणायामः';

  @override
  String get ritualStepReflect => 'विमर्शः';

  @override
  String get ritualStepSettle => 'चित्तस्थैर्यम्';

  @override
  String get ritualStepBegin => 'प्रारम्भः';

  @override
  String get ritualSkip => 'उपेक्ष्यताम्';

  @override
  String get ritualContinue => 'अनुवर्त्यताम्';

  @override
  String get ritualBreathIn => 'अन्तःश्वसितु';

  @override
  String get ritualBreathHold => 'धारयतु';

  @override
  String get ritualBreathOut => 'बहिःश्वसितु';

  @override
  String get ritualBreathRest => 'विश्राम्यतु';

  @override
  String get ritualBreathInHint => 'मन्दं श्वासम् अन्तः स्वीकुरुत...';

  @override
  String get ritualBreathHoldHint => 'श्वासं सुखेन धारयतु...';

  @override
  String get ritualBreathOutHint => 'शान्ततया श्वासं बहिः मुञ्चतु...';

  @override
  String get ritualBreathRestHint => 'सहजतया विश्राम्यतु...';

  @override
  String ritualBreathProgress(int current, int total) {
    return '$total श्वासेषु $current-तमः श्वासः';
  }

  @override
  String get ritualBreathFinished => 'प्राणायामः समाप्तः!';

  @override
  String ritualCardProgress(int number, int total) {
    return '$total पत्रेषु $number-तमं पत्रम्';
  }

  @override
  String get ritualCardAnother => 'अन्यत् पत्रं दर्शयतु';

  @override
  String get ritualMakeIntention => 'अद्यतनसङ्कल्पः';

  @override
  String get ritualIntentionSaved => 'सङ्कल्पः रक्षितः';

  @override
  String get ritualRateQuestion => 'इदं पत्रं कियत् सुलभम्?';

  @override
  String get ritualRateHard => 'कठिनम्';

  @override
  String get ritualRateRevision => 'पुनरावलोकनीयम्';

  @override
  String get ritualRateEasy => 'सुलभम्';

  @override
  String get ritualRateTomorrow => 'श्वः द्रष्टव्यम्';

  @override
  String ritualRateInDays(num days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$daysString दिनेषु',
      one: '१ दिने',
    );
    return '$_temp0';
  }

  @override
  String get ritualSettleCarryTitle => 'असमापितानि कार्याणि';

  @override
  String get ritualSettleCarryEmpty =>
      'पूर्वेभ्यो दिनेभ्यः असमापितानि कार्याणि न सन्ति।';

  @override
  String get ritualSettleFocusTitle => 'अद्यतनमुख्यकार्याणि';

  @override
  String get ritualSettleFocusHint => 'अद्यतनप्राथमिकतासु मनोयोगं कुरुत...';

  @override
  String get ritualSettleFocusEmpty => 'अद्यतनकार्याणि न चितानि।';

  @override
  String get ritualSettleFocusLimit => 'अधिकतमं ३ कार्याणि';

  @override
  String get ritualBeginTitle => 'दैनिकप्रारम्भः';

  @override
  String ritualBeginCarried(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString कार्याणि आनीतानि',
      one: '१ कार्यम् आनीतम्',
    );
    return '$_temp0';
  }

  @override
  String ritualBeginFocused(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString कार्याणि ध्याने',
      one: '१ कार्यं ध्याने',
    );
    return '$_temp0';
  }

  @override
  String get ritualBeginNothing =>
      'अद्य किमपि कार्यं नास्ति। शान्ततया विश्राम्यतु।';

  @override
  String get ritualBeginAction => 'आरभ्यताम्';

  @override
  String get ritualDeckTitle => 'ज्ञानपत्राणि';

  @override
  String get ritualDeckAll => 'सर्वाणि पत्राणि';

  @override
  String get ritualDeckDue => 'अद्य द्रष्टव्यम्';

  @override
  String get ritualDeckUnseen => 'अदृष्टानि';

  @override
  String ritualDeckSeenCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString वारं दृष्टम्',
      one: 'एकवारं दृष्टम्',
    );
    return '$_temp0';
  }

  @override
  String get ritualDeckEmpty => 'पत्राणि न सन्ति';

  @override
  String get ritualPastDayNote => 'इदं व्यतीतदिनस्य पत्रम् अस्ति।';

  @override
  String get ritualThemeDharma => 'धर्मः';

  @override
  String get ritualThemeKarma => 'कर्म';

  @override
  String get ritualThemeBhakti => 'भक्तिः';

  @override
  String get ritualThemeJnana => 'ज्ञानम्';

  @override
  String get ritualThemeYoga => 'योगः';

  @override
  String get ritualThemeAhimsa => 'अहिंसा';

  @override
  String get ritualThemeSathya => 'सत्यम्';

  @override
  String get ritualThemeVairagya => 'वैराग्यम्';

  @override
  String get ritualThemeSeva => 'सेवा';

  @override
  String get ritualThemeShanti => 'शान्तिः';

  @override
  String get ritualCardSd01Title => 'भवतः स्वधर्मः';

  @override
  String get ritualCardSd01Prompt =>
      'अस्मिन् जीवनावसरे केवलं भवता एव निर्वोढुं योग्यं विशिष्टं कर्तव्यं किम्? अद्य भवान् तत् कथं पालयति?';

  @override
  String get ritualCardSd01Quote =>
      'श्रेयान्स्वधर्मो विगुणः परधर्मात्स्वनुष्ठितात्। स्वधर्मे निधनं श्रेयः परधर्मो भयावहः॥';

  @override
  String get ritualCardSd01QuoteAuthor => 'श्रीमद्भगवद्गीता ३.३५';

  @override
  String get ritualCardSd02Title => 'लघुकार्येषु धर्मः';

  @override
  String get ritualCardSd02Prompt =>
      'अद्यतनदैनिककार्येषु सुलभमार्गात् श्रेष्ठं धर्ममार्गं भवान् कुत्र चिन्वन् अस्ति?';

  @override
  String get ritualCardSd02Quote =>
      'धारणाद्धर्ममित्याहुर्धर्मो धारयते प्रजाः। यत्स्याद्धारणसंयुक्तं स धर्म इति निश्चयः॥';

  @override
  String get ritualCardSd02QuoteAuthor => 'महाभारतम्, शान्तिपर्व १०९.१०';

  @override
  String get ritualCardSd03Title => 'धर्मचक्रम्';

  @override
  String get ritualCardSd03Prompt =>
      'रक्षितः धर्मः अस्मान् रक्षति। अद्य भवता रक्षितः धर्मः कः?';

  @override
  String get ritualCardSd03Quote =>
      'धर्म एव हतो हन्ति धर्मो रक्षति रक्षितः। तस्माद्धर्मो न हन्तव्यो मा नो धर्मो हतोऽवधीत्॥';

  @override
  String get ritualCardSd03QuoteAuthor => 'मनुस्मृतिः ८.१५';

  @override
  String get ritualCardSd04Title => 'शाश्वतः क्रमः';

  @override
  String get ritualCardSd04Prompt =>
      'यथा नद्यः समुद्रं प्रविशन्ति तथा कामाः यं प्रविशन्ति स शान्तिमाप्नोति। अद्य विचलितं मनः शान्तं कर्तुं शक्यते वा?';

  @override
  String get ritualCardSd04Quote =>
      'आपूर्यमाणमचलप्रतिष्ठं समुद्रमापः प्रविशन्ति यद्वत्। तद्वत्कामा यं प्रविशन्ति सर्वे स शान्तिमाप्नोति न कामकामी॥';

  @override
  String get ritualCardSd04QuoteAuthor => 'श्रीमद्भगवद्गीता २.७०';

  @override
  String get ritualCardSd05Title => 'आपत्सु धर्मः';

  @override
  String get ritualCardSd05Prompt =>
      'कठिनेष्वपि कालेषु धर्मः न त्याज्यः। अद्य कष्टसमयेऽपि भवान् कथं धैर्यं धारयिष्यति?';

  @override
  String get ritualCardSd05Quote => 'न जहाति हि धर्मं यः स कदाचिन्न सीदति।';

  @override
  String get ritualCardSd05QuoteAuthor => 'वाल्मीकिरामायणम्, अयोध्याकाण्डम्';

  @override
  String get ritualCardSd06Title => 'आसक्तिरहितं कर्म';

  @override
  String get ritualCardSd06Prompt =>
      'कर्मणि एव भवतः अधिकारः, फलेषु कदापि मास्तु। अद्य फलचिन्तां विहाय कर्मणि कथं मनोधीयते?';

  @override
  String get ritualCardSd06Quote =>
      'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन। मा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥';

  @override
  String get ritualCardSd06QuoteAuthor => 'श्रीमद्भगवद्गीता २.४७';

  @override
  String get ritualCardSd07Title => 'अद्य रोपितं बीजम्';

  @override
  String get ritualCardSd07Prompt =>
      'यादृशं बीजं वप्यते तादृशमेव फलं लभ्यते। अद्य भवान् कीदृशं कर्मबीजं वपति?';

  @override
  String get ritualCardSd07Quote => 'यादृशं कुरुते कर्म तादृशं फलमश्नुते।';

  @override
  String get ritualCardSd07QuoteAuthor => 'महाभारतम्, वनपर्व';

  @override
  String get ritualCardSd08Title => 'निष्कामकर्म';

  @override
  String get ritualCardSd08Prompt =>
      'कर्मफलं त्यक्त्वा ज्ञानी नैष्ठिकीं शान्तिं प्राप्नोति। अद्य निःस्वार्थभावेन कर्तुं योग्यं कार्यं किम्?';

  @override
  String get ritualCardSd08Quote =>
      'युक्तः कर्मफलं त्यक्त्वा शान्तिमाप्नोति नैष्ठिकीम्। अयुक्तः कामकारेण फले सक्तो निबध्यते॥';

  @override
  String get ritualCardSd08QuoteAuthor => 'श्रीमद्भगवद्गीता ५.१२';

  @override
  String get ritualCardSd09Title => 'अभ्यासबन्धनविमोचनम्';

  @override
  String get ritualCardSd09Prompt =>
      'कर्मेन्द्रियाणि संयम्य मनसा विषयान् यः स्मरति स विमूढात्मा। मनसः कपटं कथं वारयिष्यते?';

  @override
  String get ritualCardSd09Quote =>
      'कर्मेन्द्रियाणि संयम्य य आस्ते मनसा स्मरन्। इन्द्रियार्थान्विमूढात्मा मिथ्याचारः स उच्यते॥';

  @override
  String get ritualCardSd09QuoteAuthor => 'श्रीमद्भगवद्गीता ३.६';

  @override
  String get ritualCardSd10Title => 'दैनन्दिनकर्मयोगः';

  @override
  String get ritualCardSd10Prompt =>
      'यत्करोति तत्सर्वम् ईश्वराय समर्पयतु। अद्यतनकार्याणि समर्पणभावेन कर्तुं शक्यन्ते वा?';

  @override
  String get ritualCardSd10Quote =>
      'यत्करोषि यदश्नासि यज्जुहोषि ददासि यत्। यत्तपस्यसि कौन्तेय तत्कुरुष्व मदर्पणम्॥';

  @override
  String get ritualCardSd10QuoteAuthor => 'श्रीमद्भगवद्गीता ९.२७';

  @override
  String get ritualCardSd11Title => 'भक्तेर्हृदयम्';

  @override
  String get ritualCardSd11Prompt =>
      'पत्रं पुष्पं फलं तोयं वा भक्त्या दत्तं प्रभुः गृह्णाति। अद्य कार्येषु भवान् भक्तिभावं कथं योजयिष्यति?';

  @override
  String get ritualCardSd11Quote =>
      'पत्रं पुष्पं फलं तोयं यो मे भक्त्या प्रयच्छति। तदहं भक्त्युपहृतमश्नामि प्रयतात्मनः॥';

  @override
  String get ritualCardSd11QuoteAuthor => 'श्रीमद्भगवद्गीता ९.२६';

  @override
  String get ritualCardSd12Title => 'शरणागतिः विश्वासश्च';

  @override
  String get ritualCardSd12Prompt =>
      'सर्वान् धर्मांस्त्यक्त्वा एकं शरणं व्रज। अद्य चिन्ताः त्यक्त्वा पूर्णविश्वासः कथं स्थाप्यते?';

  @override
  String get ritualCardSd12Quote =>
      'सर्वधर्मान्परित्यज्य मामेकं शरणं व्रज। अहं त्वां सर्वपापेभ्यो मोक्षयिष्यामि मा शुचः॥';

  @override
  String get ritualCardSd12QuoteAuthor => 'श्रीमद्भगवद्गीता १८.६६';

  @override
  String get ritualCardSd13Title => 'सर्वत्र ईशदर्शनम्';

  @override
  String get ritualCardSd13Prompt =>
      'पण्डिताः समदर्शिनः भवन्ति। अद्य जनेषु भेददृष्टिं विहाय समभावः कथं पाल्यते?';

  @override
  String get ritualCardSd13Quote =>
      'विद्याविनयसम्पन्ने ब्राह्मणे गवि हस्तिनि। शुनि चैव श्वपाके च पण्डिताः समदर्शिनः॥';

  @override
  String get ritualCardSd13QuoteAuthor => 'श्रीमद्भगवद्गीता ५.१८';

  @override
  String get ritualCardSd14Title => 'पावनं नाम';

  @override
  String get ritualCardSd14Prompt =>
      'भगवन्नामस्मरणेन चित्तं निर्मलं भवति। अद्य कार्यमध्ये कतिपयक्षणान् नामस्मरणं कर्तुं शक्यते वा?';

  @override
  String get ritualCardSd14Quote =>
      'कलिजुग केवल नाम अधारा। सुमिरि सुमिरि नर उतरहिं पारा॥';

  @override
  String get ritualCardSd14QuoteAuthor =>
      'गोस्वामितुलसीदासः, श्रीरामचरितमानसम्';

  @override
  String get ritualCardSd15Title => 'कृतज्ञतायाम् अनुग्रहः';

  @override
  String get ritualCardSd15Prompt =>
      'सर्वं मत्तः एव प्रवर्तते इति मत्वा बुधाः भजन्ति। अद्य लब्धोपकारेभ्यः कृतज्ञतां कथं व्यक्तीकरिष्यति?';

  @override
  String get ritualCardSd15Quote =>
      'अहं सर्वस्य प्रभवो मत्तः सर्वं प्रवर्तते। इति मत्वा भजन्ते मां बुधा भावसमन्विताः॥';

  @override
  String get ritualCardSd15QuoteAuthor => 'श्रीमद्भगवद्गीता १०.८';

  @override
  String get ritualCardSd16Title => 'कोऽहम्?';

  @override
  String get ritualCardSd16Prompt =>
      'तत्त्वमसि — तत्त्वं भवान् एव। अद्य कार्यव्यग्रतायाः परस्तात् स्वस्य सत्यस्वरूपं स्मर्तुं शक्यते वा?';

  @override
  String get ritualCardSd16Quote =>
      'स य एषोऽणिमैतदात्म्यमिदँ सर्वं तत्सत्यं स आत्मा तत्त्वमसि श्वेतकेतो।';

  @override
  String get ritualCardSd16QuoteAuthor => 'छान्दोग्योपनिषत् ६.८.७';

  @override
  String get ritualCardSd17Title => 'शाश्वतः साक्षी';

  @override
  String get ritualCardSd17Prompt =>
      'आत्मा न जायते म्रियते वा। अद्यतनसुखदुःखेषु साक्षीभूत्वा स्थातुं शक्यते वा?';

  @override
  String get ritualCardSd17Quote =>
      'न जायते म्रियते वा कदाचिन्नायं भूत्वा भविता वा न भूयः। अजो नित्यः शाश्वतोऽयं पुराणो न हन्यते हन्यमाने शरीरे॥';

  @override
  String get ritualCardSd17QuoteAuthor => 'श्रीमद्भगवद्गीता २.२०';

  @override
  String get ritualCardSd18Title => 'मोक्षप्रदं ज्ञानम्';

  @override
  String get ritualCardSd18Prompt =>
      'ज्ञानेन सदृशं पवित्रमिह किमपि नास्ति। अद्य नूतनं ज्ञानं प्राप्तुं का योजना?';

  @override
  String get ritualCardSd18Quote =>
      'न हि ज्ञानेन सदृशं पवित्रमिह विद्यते। तत्स्वयं योगसंसिद्धः कालेनात्मनि विन्दति॥';

  @override
  String get ritualCardSd18QuoteAuthor => 'श्रीमद्भगवद्गीता ४.३८';

  @override
  String get ritualCardSd19Title => 'इन्द्रियातीतः';

  @override
  String get ritualCardSd19Prompt =>
      'इन्द्रियेभ्यः पराः अर्थाः, अर्थेभ्यः परं मनः, मनसस्तु परा बुद्धिः। अद्य इन्द्रियचाञ्चल्यं कथं निरुध्यते?';

  @override
  String get ritualCardSd19Quote =>
      'इन्द्रियेभ्यः परा ह्यर्था अर्थेभ्यश्च परं मनः। मनसस्तु परा बुद्धिर्बुद्धेरात्मा महान्परः॥';

  @override
  String get ritualCardSd19QuoteAuthor => 'कठोपनिषत् १.३.१०';

  @override
  String get ritualCardSd20Title => 'अन्तर्ज्योतिः';

  @override
  String get ritualCardSd20Prompt =>
      'असतस्त्यक्त्वा सत्यं गच्छतु, तमसः ज्योतिः गच्छतु। अद्य अज्ञानान्धकारं दूरीकर्तुं किं कार्यम्?';

  @override
  String get ritualCardSd20Quote =>
      'असतो मा सद्गमय। तमसो मा ज्योतिर्गमय। मृत्योर्माऽमृतं गमय॥';

  @override
  String get ritualCardSd20QuoteAuthor => 'बृहदारण्यकोपनिषत् १.३.२८';

  @override
  String get ritualCardSd21Title => 'पूर्णता';

  @override
  String get ritualCardSd21Prompt =>
      'पूर्णमदः पूर्णमिदं पूर्णात् पूर्णम् उदच्यते। जीवने सर्वदा पूर्णतायाः अनुभवः कथं प्राप्यते?';

  @override
  String get ritualCardSd21Quote =>
      'ॐ पूर्णमदः पूर्णमिदं पूर्णात्पूर्णमुदच्यते। पूर्णस्य पूर्णमादाय पूर्णमेवावशिष्यते॥';

  @override
  String get ritualCardSd21QuoteAuthor => 'ईशावास्योपनिषत्, शान्तिमन्त्रः';

  @override
  String get ritualCardSd22Title => 'सर्वत्र ब्रह्म';

  @override
  String get ritualCardSd22Prompt =>
      'अहं ब्रह्मास्मि। आत्मनः दिव्यस्वरूपम् अद्य कथं प्रकाशयिष्यति?';

  @override
  String get ritualCardSd22Quote =>
      'ब्रह्म वा इदमग्र आसीत्तदात्मानमेवावेत्। अहं ब्रह्मास्मीति तस्मात्तत्सर्वमभवत्॥';

  @override
  String get ritualCardSd22QuoteAuthor => 'बृहदारण्यकोपनिषत् १.४.१०';

  @override
  String get ritualCardSd23Title => 'चित्तवृत्तिनिरोधः';

  @override
  String get ritualCardSd23Prompt =>
      'योगश्चित्तवृत्तिनिरोधः। अद्य चञ्चलं चित्तं शान्तं कर्तुं कति क्षणाः दीयन्ते?';

  @override
  String get ritualCardSd23Quote => 'योगश्चित्तवृत्तिनिरोधः॥';

  @override
  String get ritualCardSd23QuoteAuthor => 'पतञ्जलियोगसूत्राणि १.२';

  @override
  String get ritualCardSd24Title => 'दृढोऽभ्यासः';

  @override
  String get ritualCardSd24Prompt =>
      'दीर्घकालनैरन्तर्येण अभ्यासः दृढभूमिः भवति। अद्य स्वीयं कार्यम् अविच्छिन्नश्रद्धया कर्तुं शक्यते वा?';

  @override
  String get ritualCardSd24Quote =>
      'स तु दीर्घकालनैरन्तर्यसत्कारासेवितो दृढभूमिः॥';

  @override
  String get ritualCardSd24QuoteAuthor => 'पतञ्जलियोगसूत्राणि १.१४';

  @override
  String get ritualCardSd25Title => 'समत्वं योगः';

  @override
  String get ritualCardSd25Prompt =>
      'सिद्ध्यसिद्ध्योः समो भूत्वा कर्माणि कुरुत। अद्य लाभेऽलाभे च समभावः कथं रक्ष्यते?';

  @override
  String get ritualCardSd25Quote =>
      'योगस्थः कुरु कर्माणि सङ्गं त्यक्त्वा धनञ्जय। सिद्ध्यसिद्ध्योः समो भूत्वा समत्वं योग उच्यते॥';

  @override
  String get ritualCardSd25QuoteAuthor => 'श्रीमद्भगवद्गीता २.४८';

  @override
  String get ritualCardSd26Title => 'पञ्च यमाः';

  @override
  String get ritualCardSd26Prompt =>
      'अहिंसा, सत्यम्, अस्तेयम्, ब्रह्मचर्यम्, अपरिग्रहश्च। अद्य एतेषु कमपि एकं नियमं पालयितुं शक्यते वा?';

  @override
  String get ritualCardSd26Quote =>
      'अहिंसा-सत्य-अस्तेय-ब्रह्मचर्य-अपरिग्रहश्चेति यमाः॥';

  @override
  String get ritualCardSd26QuoteAuthor => 'पतञ्जलियोगसूत्राणि २.३०';

  @override
  String get ritualCardSd27Title => 'ईश्वरप्रणिधानम्';

  @override
  String get ritualCardSd27Prompt =>
      'ईश्वरे पूर्णसमर्पणेन समाधिसिद्धिः भवति। अद्य स्वीयभारम् ईश्वरे निक्षिप्य शान्तिः प्राप्यताम्।';

  @override
  String get ritualCardSd27Quote => 'समाधिसिद्धिरीश्वरप्रणिधानात्॥';

  @override
  String get ritualCardSd27QuoteAuthor => 'पतञ्जलियोगसूत्राणि २.४५';

  @override
  String get ritualCardSd28Title => 'अहिंसा परमो धर्मः';

  @override
  String get ritualCardSd28Prompt =>
      'अहिंसा केवलं शरीरेण न, मनसापि पालनीया। अद्य कस्यापि विषये कटुचिन्तनं कथं वारयिष्यति?';

  @override
  String get ritualCardSd28Quote =>
      'अहिंसा परमो धर्मस्तथाहिंसा परं दमः। अहिंसा परमं दानमहिंसा परमं तपः॥';

  @override
  String get ritualCardSd28QuoteAuthor => 'महाभारतम्, अनुशासनपर्व ११६.३८';

  @override
  String get ritualCardSd29Title => 'सर्वभूतेषु दया';

  @override
  String get ritualCardSd29Prompt =>
      'यः सर्वभूतान्यात्मन्येव पश्यति स न विजुगुप्सते। अद्य सर्वेषु जीवेषु आत्मीयभावः कथं द्रष्टव्यः?';

  @override
  String get ritualCardSd29Quote =>
      'यस्तु सर्वाणि भूतान्यात्मन्येवानुपश्यति। सर्वभूतेषु चात्मानं ततो न विजुगुप्सते॥';

  @override
  String get ritualCardSd29QuoteAuthor => 'ईशावास्योपनिषत्, श्लोकः ६';

  @override
  String get ritualCardSd30Title => 'प्रियं वाक्यम्';

  @override
  String get ritualCardSd30Prompt =>
      'अनुद्वेगकरं सत्यं प्रियं हितं च वाक्यं वाङ्मयं तपः। अद्य भाषणे माधुर्यं कथं रक्षिष्यति?';

  @override
  String get ritualCardSd30Quote =>
      'अनुद्वेगकरं वाक्यं सत्यं प्रियहितं च यत्। स्वाध्यायाभ्यसनं चैव वाङ्मयं तप उच्यते॥';

  @override
  String get ritualCardSd30QuoteAuthor => 'श्रीमद्भगवद्गीता १७.१५';

  @override
  String get ritualCardSd31Title => 'क्षमया जयः';

  @override
  String get ritualCardSd31Prompt =>
      'क्षमा बलवतां भूषणम्। अद्य केनापि कृतापराधं क्षन्तुं मनः सज्जं वा?';

  @override
  String get ritualCardSd31Quote =>
      'एकः क्षमावतां दोषो द्वितीयो नोपपद्यते। यदेनं क्षमया युक्तमशक्तं मन्यते जनः॥';

  @override
  String get ritualCardSd31QuoteAuthor => 'महाभारतम्, उद्योगपर्व ३३.४८';

  @override
  String get ritualCardSd32Title => 'सत्यमेव जयते';

  @override
  String get ritualCardSd32Prompt =>
      'सत्यमेव जयते नानृतम्। अद्य सर्वव्यवहारेषु सत्यनिष्ठा कथं पालनीया?';

  @override
  String get ritualCardSd32Quote =>
      'सत्यमेव जयते नानृतं सत्येन पन्था विततो देवयानः। येनाक्रमन्त्यृषयो ह्याप्तकामा यत्र तत् सत्यस्य परमं निधानम्॥';

  @override
  String get ritualCardSd32QuoteAuthor => 'मुण्डकोपनिषत् ३.१.६';

  @override
  String get ritualCardSd33Title => 'सत्यं वद धर्मं चर';

  @override
  String get ritualCardSd33Prompt =>
      'सत्यं वद, धर्मं चर। अद्य स्वकर्मणि ऋजुता कथं स्थापनीया?';

  @override
  String get ritualCardSd33Quote =>
      'सत्यं वद। धर्मं चर। स्वाध्यायान्मा प्रमदः।';

  @override
  String get ritualCardSd33QuoteAuthor => 'तैत्तिरीयोपनिषत् १.११.१';

  @override
  String get ritualCardSd34Title => 'सत्यस्य महिमा';

  @override
  String get ritualCardSd34Prompt =>
      'सत्येन धार्यते पृथ्वी। अद्य सत्यनिष्ठया आत्मबलं कथं वर्धयिष्यति?';

  @override
  String get ritualCardSd34Quote =>
      'सत्येन धार्यते पृथ्वी सत्येन तपते रविः। सत्येन वाति वायुश्च सर्वं सत्ये प्रतिष्ठितम्॥';

  @override
  String get ritualCardSd34QuoteAuthor => 'चाणक्यनीतिः १४.३';

  @override
  String get ritualCardSd35Title => 'प्रतिज्ञापालनम्';

  @override
  String get ritualCardSd35Prompt =>
      'स्वस्मै दतं वचनं पालयतु। अद्यतनसङ्कल्पपालने दृढता अस्ति वा?';

  @override
  String get ritualCardSd35Quote => 'सत्ये सर्वं प्रतिष्ठितम्।';

  @override
  String get ritualCardSd35QuoteAuthor => 'विदुरनीतिः, महाभारतम्';

  @override
  String get ritualCardSd36Title => 'वैराग्यम्';

  @override
  String get ritualCardSd36Prompt =>
      'विषयतृष्णात्यागः वैराग्यम्। अद्य अनपेक्षितचिन्ताः त्यक्त्वा शान्तिः कथं लभ्यते?';

  @override
  String get ritualCardSd36Quote =>
      'दृष्टानुश्रविकविषयवितृष्णस्य वशीकारसंज्ञा वैराग्यम्॥';

  @override
  String get ritualCardSd36QuoteAuthor => 'पतञ्जलियोगसूत्राणि १.१५';

  @override
  String get ritualCardSd37Title => 'सत्यं शाश्वतम्';

  @override
  String get ritualCardSd37Prompt =>
      'नासतो विद्यते भावो नाभावो विद्यते सतः। नश्वरवस्तूनां चिन्तां विहाय शाश्वतं स्मरतु।';

  @override
  String get ritualCardSd37Quote =>
      'नासतो विद्यते भावो नाभावो विद्यते सतः। उभयोरपि दृष्टोऽन्तस्त्वनयोस्तत्त्वदर्शिभिः॥';

  @override
  String get ritualCardSd37QuoteAuthor => 'श्रीमद्भगवद्गीता २.१६';

  @override
  String get ritualCardSd38Title => 'सन्तोषः';

  @override
  String get ritualCardSd38Prompt =>
      'सन्तोषादनुत्तमः सुखलाभः। अद्य लब्धेन सन्तोषमनुभवितुं मनः सज्जं वा?';

  @override
  String get ritualCardSd38Quote => 'सन्तोषादनुत्तमः सुखलाभः॥';

  @override
  String get ritualCardSd38QuoteAuthor => 'पतञ्जलियोगसूत्राणि २.४२';

  @override
  String get ritualCardSd39Title => 'द्वन्द्वातीतः';

  @override
  String get ritualCardSd39Prompt =>
      'सुखदुःखयोः समो भूत्वा धीरः अमृतत्वाय कल्पते। अद्य अनुकूलप्रतिकूलपरिस्थितौ समचित्तता कथं पाल्यते?';

  @override
  String get ritualCardSd39Quote =>
      'यं हि न व्यथयन्त्येते पुरुषं पुरुषर्षभ। समदुःखसुखं धीरं सोऽमृतत्वाय कल्पते॥';

  @override
  String get ritualCardSd39QuoteAuthor => 'श्रीमद्भगवद्गीता २.१५';

  @override
  String get ritualCardSd40Title => 'दानस्यानन्दः';

  @override
  String get ritualCardSd40Prompt =>
      'दानं परोपकारश्च जीवनस्य भूषणम्। अद्य कस्यचित् साहाय्यं कर्तुम् अवसरः अस्ति वा?';

  @override
  String get ritualCardSd40Quote =>
      'परोपकाराय फलन्ति वृक्षाः परोपकाराय वहन्ति नद्यः। परोपकाराय दुहन्ति गावः परोपकारार्थमिदं शरीरम्॥';

  @override
  String get ritualCardSd40QuoteAuthor => 'तिरुक्कुरळ् २२१ / सुभाषितम्';

  @override
  String get ritualCardSd41Title => 'नरसेवा नारायणसेवा';

  @override
  String get ritualCardSd41Prompt =>
      'दीनेषु दरिद्रेषु च ईश्वरं पश्यतु। अद्य केषाञ्चित् सेवां कर्तुं मनः प्रेरयतु।';

  @override
  String get ritualCardSd41Quote =>
      'जीवे दया, ईश्वरे प्रीतिः। यः जीवानां सेवां करोति स ईश्वरस्यैव सेवां करोति।';

  @override
  String get ritualCardSd41QuoteAuthor => 'स्वामी विवेकानन्दः';

  @override
  String get ritualCardSd42Title => 'उत्तिष्ठत जाग्रत';

  @override
  String get ritualCardSd42Prompt =>
      'उत्तिष्ठत जाग्रत प्राप्य वरान्निबोधत। आलस्यं त्यक्त्वा कर्मणि प्रवृत्तो भवतु।';

  @override
  String get ritualCardSd42Quote =>
      'उत्तिष्ठत जाग्रत प्राप्य वरान्निबोधत। क्षुरस्य धारा निशिता दुरत्यया दुर्गं पथस्तत्कवयो वदन्ति॥';

  @override
  String get ritualCardSd42QuoteAuthor =>
      'कठोपनिषत् १.३.१४ / स्वामी विवेकानन्दः';

  @override
  String get ritualCardSd43Title => 'वसुधैव कुटुम्बकम्';

  @override
  String get ritualCardSd43Prompt =>
      'उदारचरितानां तु वसुधैव कुटुम्बकम्। अद्य स्वीयप्रेमसीमाः कथं विस्तारयिष्यति?';

  @override
  String get ritualCardSd43Quote =>
      'अयं निजः परो वेति गणना लघुचेतसाम्। उदारचरितानां तु वसुधैव कुटुम्बकम्॥';

  @override
  String get ritualCardSd43QuoteAuthor => 'महोपनिषत् ६.७१';

  @override
  String get ritualCardSd44Title => 'दयायाः धनम्';

  @override
  String get ritualCardSd44Prompt =>
      'दयालुभावेन कृतं दानं दारिद्र्यमपि नाशयति। अद्य स्नेहेन व्यवहारं कर्तुं सङ्कल्पः अस्ति वा?';

  @override
  String get ritualCardSd44Quote => 'दया सर्वभूतेषु परमं धनम्।';

  @override
  String get ritualCardSd44QuoteAuthor => 'तिरुक्कुरळ् २४७';

  @override
  String get ritualCardSd45Title => 'आन्तरिकी शान्तिः';

  @override
  String get ritualCardSd45Prompt =>
      'आत्मनैवात्मा जितः चेत् मनः परममित्रं भवति। अद्य अन्तर्मुखो भूत्वा शान्तिः अनुभूयताम्।';

  @override
  String get ritualCardSd45Quote =>
      'बन्धुरात्मात्मनस्तस्य येनात्मैवात्मना जितः। अनात्मनस्तु शत्रुत्वे वर्तेतात्मैव शत्रुवत्॥';

  @override
  String get ritualCardSd45QuoteAuthor => 'श्रीमद्भगवद्गीता ६.६';

  @override
  String get ritualCardSd46Title => 'स्तुतिनिन्दयोः समभावः';

  @override
  String get ritualCardSd46Prompt =>
      'मानापमानयोः समः सङ्गविवर्जितः पुरुषः प्रियः। अद्य प्रशंसासु निन्दासु च समचित्तता कथं रक्ष्यते?';

  @override
  String get ritualCardSd46Quote =>
      'समः शत्रौ च मित्रे च तथा मानापमानयोः। शीतोष्णसुखदुःखेषु समः सङ्गविवर्जितः॥';

  @override
  String get ritualCardSd46QuoteAuthor => 'श्रीमद्भगवद्गीता १२.१८–१९';

  @override
  String get ritualCardSd47Title => 'पङ्के पद्मम्';

  @override
  String get ritualCardSd47Prompt =>
      'पद्मपत्रमिवाम्भसा न लिप्यते यः कर्माणि ब्रह्मणि समर्प्य करोति। संसारे स्थित्वाप्यलिप्तता कथं साध्यते?';

  @override
  String get ritualCardSd47Quote =>
      'ब्रह्मण्याधाय कर्माणि सङ्गं त्यक्त्वा करोति यः। लिप्यते न स पापेन पद्मपत्रमिवाम्भसा॥';

  @override
  String get ritualCardSd47QuoteAuthor => 'श्रीमद्भगवद्गीता ५.१०';

  @override
  String get ritualCardSd48Title => 'ॐ शान्तिः';

  @override
  String get ritualCardSd48Prompt =>
      'त्रिवारम् ॐ शान्तिः इति जपतु — शरीरे, मनसि, आत्मनि च। अशान्तिः कथम् अपगच्छति?';

  @override
  String get ritualCardSd48Quote => 'ॐ शान्तिः शान्तिः शान्तिः॥';

  @override
  String get ritualCardSd48QuoteAuthor => 'उपनिषत् शान्तिमन्त्रः';

  @override
  String get ritualCardSd49Title => 'सर्वे भवन्तु सुखिनः';

  @override
  String get ritualCardSd49Prompt =>
      'सर्वप्राणिनां मङ्गलं कामयतु। सर्वेषां सुखाय हृदयं विस्तारयतु।';

  @override
  String get ritualCardSd49Quote =>
      'सर्वे भवन्तु सुखिनः सर्वे सन्तु निरामयाः। सर्वे भद्राणि पश्यन्तु मा कश्चिद्दुःखभाग्भवेत्॥';

  @override
  String get ritualCardSd49QuoteAuthor => 'उपनिषत् प्रार्थना';

  @override
  String get ritualCardSd50Title => 'बलं शान्तिश्च';

  @override
  String get ritualCardSd50Prompt =>
      'यथार्थं बलं शान्तेः उत्पद्यते। अद्य भयमुद्वेगं च त्यक्त्वा शान्तबलेन कार्यं क्रियताम्।';

  @override
  String get ritualCardSd50Quote =>
      'बलमेव जीवनम्, दौर्बल्यमेव मृत्युः। बलमेव औषधम्, बलमेव कल्याणम्।';

  @override
  String get ritualCardSd50QuoteAuthor => 'स्वामी विवेकानन्दः';

  @override
  String get pendingAlertsTitle => 'अवशिष्टकार्याणां स्मारणम्';

  @override
  String get pendingAlertsSubtitle => 'दिनावसाने असमापितानि कार्याणि स्मारयतु';

  @override
  String get pendingAlertsEnabled => 'स्मारणानि प्रयुज्यन्ताम्';

  @override
  String get pendingAlertsEnabledDetail =>
      'असमापितकार्याणां स्मारणार्थं सूचनाः दर्शयतु।';

  @override
  String get pendingAlertsDayStart => 'दिनप्रारम्भस्मारणम्';

  @override
  String get pendingAlertsDayStartDetail =>
      'दिनस्य प्रारम्भे अवशिष्टानि कार्याणि सूच्यन्ताम्।';

  @override
  String get pendingAlertsDayStartTime => 'स्मारणसमयः';

  @override
  String get pendingAlertsInterval => 'स्मारणान्तरालम्';

  @override
  String get pendingAlertsIntervalDetail => 'कियता कालेन स्मारणं भवेत्।';

  @override
  String get pendingAlertsIntervalOff => 'पिहितम्';

  @override
  String get pendingAlertsInterval30m => '३० निमेषाः';

  @override
  String get pendingAlertsInterval1h => '१ घण्टा';

  @override
  String get pendingAlertsInterval2h => '२ घण्टे';

  @override
  String get pendingAlertsInterval3h => '३ घण्टाः';

  @override
  String get pendingAlertsInterval4h => '४ घण्टाः';

  @override
  String get pendingAlertsHaptic => 'कम्पनम्';

  @override
  String get pendingAlertsHapticDetail => 'स्मारणे सति सूक्ष्मं कम्पनम्।';

  @override
  String get pendingAlertsPreview => 'स्मारणपूर्वावलोकनम्';

  @override
  String get pendingAlertsSheetTitle => 'अद्यापि अवशिष्टानि कार्याणि';

  @override
  String pendingAlertsSheetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'अद्य $count कार्याणि अवशिष्टानि',
      one: 'अद्य १ कार्यम् अवशिष्टम्',
    );
    return '$_temp0';
  }

  @override
  String get pendingAlertsSheetEmpty => 'अद्य सर्वाणि कार्याणि समापितानि!';

  @override
  String get pendingAlertsStartTimer => 'समयगणनम् आरभ्यताम्';

  @override
  String get pendingAlertsGoToToday => 'अद्यतनदिने पश्यतु';

  @override
  String get pendingAlertsSnooze => 'अनन्तरं स्मारयतु';

  @override
  String get pendingAlertsDismiss => 'पिधीयताम्';

  @override
  String get trackingRunningNotification => 'प्रवर्तमानसमयगणनम्';

  @override
  String get trackingRunningNotificationDetail =>
      'यन्त्रस्य पटलशीर्षे समयगणकं दर्शयतु।';

  @override
  String get permissionsNotificationTitle => 'अधिसूचनाः';

  @override
  String get permissionsNotificationBody =>
      'समयगणकस्य स्मारणस्य च सूचनायै प्रयुज्यते।';

  @override
  String get pendingAlertsTodaySection => 'अद्यतनकार्याणि';

  @override
  String get pendingAlertsPreviousSection => 'पूर्वतनकार्याणि';

  @override
  String get pendingAlertsPortToToday => 'अद्य आनयतु';

  @override
  String get pendingAlertsPortedSuccess => 'कार्याणि अद्य आनीतानि';

  @override
  String get pendingAlertsNotificationTitle =>
      'असमापितानि कार्याणि प्रतीक्षन्ते';

  @override
  String pendingAlertsNotificationBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'भवतः $count कार्याणि अवशिष्टानि सन्ति',
      one: 'भवतः १ कार्यम् अवशिष्टम् अस्ति',
    );
    return '$_temp0';
  }

  @override
  String get taskHistory => 'कार्यस्येतिवृत्तम्';

  @override
  String get taskHistorySubtitle => 'कार्ये कृतानि परिवर्तनानि';

  @override
  String get taskHistoryEmpty => 'इतिवृत्तं नास्ति';

  @override
  String get eventCreated => 'कार्यं सृष्टम्';

  @override
  String get eventMoved => 'कार्यं स्थानान्तरितम्';

  @override
  String eventMovedFromTo(String fromDate, String toDate) {
    return '$fromDate तः $toDate दिने स्थानान्तरितम्';
  }

  @override
  String get eventTimerStarted => 'समयगणनम् आरब्धम्';

  @override
  String eventTimerStopped(String duration) {
    return 'समयगणनं विरतम् ($duration)';
  }

  @override
  String eventTimerPaused(String duration) {
    return 'समयगणनं स्थगितम् ($duration)';
  }

  @override
  String eventManualSegment(String duration) {
    return 'हस्तचालितसमयः योजितः ($duration)';
  }

  @override
  String eventStatusChanged(String status) {
    return 'स्थितिः $status इति परिवर्तिता';
  }

  @override
  String get eventSubtaskToggled => 'उपकार्यस्थितिः परिवर्तिता';

  @override
  String get eventEdited => 'कार्यं सम्पादितम्';

  @override
  String get moveToToday => 'अद्यतनदिने स्थानान्तर्यताम्';

  @override
  String get taskMovedToToday => 'कार्यम् अद्यतनदिने आनीतम्';

  @override
  String taskMovedSuccess(String date) {
    return 'कार्यं $date दिने स्थानान्तरितम्';
  }

  @override
  String get editSegmentTime => 'समयखण्डं सम्पाद्यताम्';

  @override
  String get segmentTimeUpdated => 'समयखण्डः अद्यतनीकृतः';

  @override
  String get segmentEditedBadge => 'सम्पादितम्';

  @override
  String get segmentEditedAfterCompletionTooltip =>
      'कार्यसमापनानन्तरम् अयं खण्डः सम्पादितः।';

  @override
  String segmentEditedOn(String when) {
    return '$when सम्पादितम्';
  }

  @override
  String get cannotEditRunningSegment =>
      'प्रवर्तमानः खण्डः सम्पादयितुं न शक्यते। प्रथमं विरम्यताम्।';

  @override
  String get moveTodo => 'कार्यं स्थानान्तर्यताम्';

  @override
  String get moveTodoTo => 'अत्र स्थानान्तर्यताम्';

  @override
  String get notStartedYet => 'अद्यापि नारब्धम्';

  @override
  String get ocrScanTitle => 'पाठप्रत्यभिज्ञा (OCR)';

  @override
  String get ocrScanSubtitle => 'चित्रे विद्यमानं पाठं पश्यतु';

  @override
  String get ocrScanHint => 'चित्रे विद्यमानं पाठं पश्यतु...';

  @override
  String get ocrCaptureTooltip => 'चित्रं गृह्णातु';

  @override
  String get ocrTorchAuto => 'स्वचालितप्रकाशः';

  @override
  String get ocrTorchOn => 'प्रकाशः प्रज्वलितः';

  @override
  String get ocrTorchOff => 'प्रकाशः निर्वापितः';

  @override
  String get ocrSwitchCamera => 'छायाग्राही परिवर्त्यताम्';

  @override
  String get ocrPickGallery => 'चित्रागारात् चिनोतु';

  @override
  String get ocrProcessing => 'चित्रं विश्लेष्यते...';

  @override
  String get ocrPreparingImage => 'चित्रं सज्जीक्रियते...';

  @override
  String get ocrFocusLocked => 'केन्द्रबिन्दुः स्थिरः';

  @override
  String get ocrNoTextFound => 'चित्रे पाठः न प्राप्तः';

  @override
  String get ocrReviewTitle => 'कार्याणां पुनरावलोकनम्';

  @override
  String get ocrTaskNameLabel => 'कार्यशीर्षकम्';

  @override
  String get ocrTaskNameEmpty => 'शीर्षकं रिक्तं नार्हति';

  @override
  String get ocrDescriptionLabel => 'वर्णनम्';

  @override
  String get ocrRawTextTitle => 'मूलपाठः';

  @override
  String get ocrRawTextCopied => 'मूलपाठः प्रतिलिखितः';

  @override
  String get ocrCreateTask => 'कार्यं सृज्यताम्';

  @override
  String get ocrOpenInEditor => 'सम्पादके उद्घाट्यताम्';

  @override
  String get ocrRetake => 'पुनर्गृह्यताम्';

  @override
  String get ocrCameraPermissionRequired => 'छायाग्राह्यानुमतिः आवश्यकी';

  @override
  String get ocrApplyToForm => 'रूपके प्रयुज्यताम्';

  @override
  String get ocrScanButtonTooltip => 'चित्रं गृह्णातु';

  @override
  String get ocrCropTitle => 'चित्रं कृत्य कुरुत';

  @override
  String get ocrCropHint => 'उपयुक्तभागं चिनोतु';

  @override
  String get ocrCropConfirm => 'कर्तनं स्थिरीकुरुत';

  @override
  String get ocrCropFullImage => 'पूर्णं चित्रम्';

  @override
  String get ocrBrightnessLabel => 'दीप्तिः';

  @override
  String get ocrZoomLabel => 'विस्तारः';

  @override
  String get ocrResetExposure => 'प्रकाशं पुनःसज्जीकुरुत';

  @override
  String get ocrRotateImage => 'चित्रं भ्रामयतु';

  @override
  String get ocrSwapFields => 'क्षेत्राणि विनिमयतु';

  @override
  String get ocrContinueToCreate => 'कार्यनिर्माणायाग्रे गच्छतु';

  @override
  String get ocrFilterOriginal => 'मूलरूपम्';

  @override
  String get ocrFilterBw => 'कृष्णधवलम्';

  @override
  String get ocrFilterBrighten => 'दीप्तिमत्';

  @override
  String get ocrEnhanceLabel => 'उत्कृष्टता';

  @override
  String get ocrRotateCw => 'दक्षिणावर्तं भ्रामयतु';

  @override
  String get ocrRotateCcw => 'वामावर्तं भ्रामयतु';

  @override
  String get ocrFilterGrayscale => 'कृष्णधवलरूपम्';

  @override
  String get ocrTabCrop => 'कर्तनम्';

  @override
  String get ocrTabFilters => 'शोधकाः';

  @override
  String get ocrTabTune => 'परिशोधनम्';

  @override
  String get ocrContrastLabel => 'वर्णान्तरम्';

  @override
  String get ocrResetFilter => 'शोधकं पुनःसज्जीकुरुत';

  @override
  String get masteryDecksTitle => 'ज्ञानकोशाः';

  @override
  String get newMasteryDeck => 'नूतनज्ञानसङ्ग्रहः';

  @override
  String get masteryDeckName => 'सङ्ग्रहनाम';

  @override
  String get masteryDeckNameHint => 'यथा: \'संस्कृतधातुपाठाः\'...';

  @override
  String get masteryDeckDescription => 'विवरणम्';

  @override
  String get noMasteryDecks => 'ज्ञानकोशाः न सन्ति';

  @override
  String get noMasteryDecksSubtitle => 'नूतनं ज्ञानसङ्ग्रहं सृजतु।';

  @override
  String get noMasteryTodos => 'कार्याणि न सन्ति';

  @override
  String get noMasteryTodosSubtitle => 'अस्मिन् कोशे कार्याणि योजयतु।';

  @override
  String get addTodoToDeck => 'कोशे योज्यताम्';

  @override
  String get masteryOverallProgress => 'समग्रप्रगतिः';

  @override
  String masteryTasksCount(int completed, int total) {
    return '$total कार्येषु $completed समापितानि';
  }

  @override
  String get masteryDeckTag => 'ज्ञानसूचकः';

  @override
  String get allMasteryFilter => 'सर्वाणि ज्ञानपत्राणि';

  @override
  String get deleteDeck => 'सङ्ग्रहं लोप्यताम्';

  @override
  String get deleteDeckConfirmation => 'अयं ज्ञानसङ्ग्रहः लुप्यतां वा?';

  @override
  String get ocrEnhanceTitle => 'चित्रशोधनम्';

  @override
  String get ocrEnhanceUseText => 'पाठं प्रयुङ्क्तु';

  @override
  String get ocrEnhanceCrop => 'कर्तनम्';

  @override
  String get ocrEnhanceInvert => 'विपर्ययः';

  @override
  String get ocrEnhanceLiveText => 'प्रत्यक्षपाठः';

  @override
  String get ocrEnhanceLiveTextNone => 'पाठः न दृष्टः';

  @override
  String ocrEnhanceWordCount(int count) {
    return '$count शब्दाः';
  }

  @override
  String get ocrEnhanceScanning => 'अन्विष्यते...';

  @override
  String get ocrLanguageTooltip => 'पाठभाषा';

  @override
  String get ocrLanguageAll => 'सर्वाः भाषाः';

  @override
  String get ocrLanguageMalayalam => 'മലയാളം';

  @override
  String get ocrLanguageEnglish => 'English';

  @override
  String get tooltipClose => 'पिधीयताम्';

  @override
  String get tooltipRefresh => 'नवीक्रियताम्';

  @override
  String get tooltipClear => 'मार्जयतु';

  @override
  String get tooltipTogglePassword => 'गुप्तपदं दर्शयतु/निगूहयतु';

  @override
  String get tooltipRemoveTask => 'कार्यम् अपनयतु';

  @override
  String get tooltipRemoveSubTask => 'उपकार्यम् अपनयतु';

  @override
  String get tooltipToggleStatus => 'स्थितिं परिवर्तयतु';

  @override
  String get tooltipMoreOptions => 'अधिकविकल्पाः';

  @override
  String get tooltipVoiceRecord => 'वाणीनिर्देशम् आरभताम्';

  @override
  String get tooltipAirQrShare => 'AirQR प्रसारः';

  @override
  String get tooltipAirQrScan => 'AirQR छायाग्राही';

  @override
  String get tooltipCopyPairingDetails => 'युग्मविवरणं प्रतिलिख्यताम्';

  @override
  String airQrBackupReceived(int count) {
    return 'AirQR प्रतिरक्षा लब्धा ($count कार्याणि)।';
  }

  @override
  String airQrSyncComplete(int count) {
    return 'AirQR समकालनं समाप्तम्: $count कार्याणि आनीतानि।';
  }

  @override
  String get navMastery => 'ज्ञानपत्राणि';

  @override
  String dataHandoffExportSuccess(String fileName) {
    return '$fileName सञ्चिकायां रक्षितम्';
  }

  @override
  String dataHandoffExportFailed(String error) {
    return 'निर्यातः विफलः: $error';
  }

  @override
  String get dataHandoffSaveMarkdown => 'Markdown सञ्चिकारूपेण रक्षतु';

  @override
  String dataHandoffSavedMarkdown(String fileName) {
    return '$fileName सञ्चिकायां रक्षितम्';
  }

  @override
  String get dataHandoffCopyMarkdown => 'Markdown सूचीं प्रतिलिख्यताम्';

  @override
  String get dataHandoffCopiedMarkdown => 'Markdown सूची प्रतिलिखिता';

  @override
  String get dataHandoffDayLockedError =>
      'कीलितदिनात् दत्तांशं परिवर्तयितुं न शक्यते।';

  @override
  String dataHandoffImportSuccess(int count, String date) {
    return '$date दिने $count कार्याणि साफल्येन आनीतानि।';
  }

  @override
  String dataHandoffImportFailed(String error) {
    return 'आनायनं विफलम्: $error';
  }

  @override
  String dataHandoffImportedTasks(int count, String date) {
    return '$date दिने $count कार्याणि आनीतानि।';
  }

  @override
  String ocrImageCaptureFailed(String error) {
    return 'चित्रग्रहणं विफलम्: $error';
  }

  @override
  String ocrImagePickFailed(String error) {
    return 'चित्रचयनं विफलम्: $error';
  }

  @override
  String get p2pEnterHostDetailsPrompt => 'यन्त्रस्य सङ्केतं प्रविशतु';

  @override
  String get p2pInvalidPortPrompt => 'अमान्यो द्वारसङ्केतः';

  @override
  String p2pSyncFailedMessage(String error) {
    return 'P2P समकालनं विफलम्: $error';
  }

  @override
  String get p2pPayloadCopiedMessage => 'समकालनदत्तांशः प्रतिलिखितः';

  @override
  String get airQrPayloadFormatError => 'AirQR दत्तांशरूपम् अशुद्धम्';

  @override
  String get airQrSkipDuplicates => 'द्विरुक्तानि उपेक्षताम्';

  @override
  String get airQrImportAll => 'सर्वाणि आनयतु';

  @override
  String get airQrStreamGenError => 'AirQR धाराजनने दोषः जातः';

  @override
  String get dayLockedBadge => 'कीलितम्';

  @override
  String get p2pSyncSummaryTitle => 'समकालनसारांशः';

  @override
  String get p2pScreenTitle => 'स्थानीय P2P Wi-Fi समकालनम्';

  @override
  String get p2pConnectAndSync => 'सम्बध्य समकालं कुरुत';

  @override
  String get p2pOptionTodayTasks => 'अद्यतनकार्याणि';

  @override
  String get p2pOptionTodayTasksSubtitle => 'अद्यतनसक्रियकार्यसूच्याः समकालनम्';

  @override
  String get p2pOptionTimeSegments => 'समयखण्डाः';

  @override
  String get p2pOptionTimeSegmentsSubtitle => 'गणितसमयवृत्तान्तानां समकालनम्';

  @override
  String get p2pOptionRecurrenceRules => 'पुनरावृत्तिनियमाः';

  @override
  String get p2pOptionRecurrenceRulesSubtitle => 'पुनरावृत्तियोजनानां समकालनम्';

  @override
  String get p2pOptionMasteryDeck => 'ज्ञानपत्राणि';

  @override
  String get p2pOptionMasteryDeckSubtitle => 'ज्ञानपत्राणां समकालनम्';

  @override
  String airQrDatePrefix(String date) {
    return 'दिनाङ्कः: $date';
  }

  @override
  String get airQrFrameRenderError => 'खण्डचित्रणे दोषः';

  @override
  String deckLoadError(String error) {
    return 'पत्रसङ्ग्रहस्योद्घाटने दोषः: $error';
  }

  @override
  String get deckNotFound => 'पत्रसङ्ग्रहः न प्राप्तः';

  @override
  String deckTasksLoadError(String error) {
    return 'कार्योद्घाटने दोषः: $error';
  }

  @override
  String decksLoadError(String error) {
    return 'पत्राणामुद्घाटने दोषः: $error';
  }
}
