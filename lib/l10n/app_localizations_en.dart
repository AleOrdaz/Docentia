// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Docentia';

  @override
  String get navHome => 'Home';

  @override
  String get navCourses => 'Courses';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navFinance => 'Finance';

  @override
  String get navProfile => 'Profile';

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get create => 'Create';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get loading => 'Loading...';

  @override
  String get description => 'Description';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get viewCode => 'View code';

  @override
  String get loginTitle => 'Docentia';

  @override
  String get loginSubtitle =>
      'The smart academic management and attendance tracking platform designed for modern educators.';

  @override
  String get loginFeature1 => 'Fast Attendance Tracking';

  @override
  String get loginFeature2 => 'Direct Notifications';

  @override
  String get loginFeature3 => 'Clear Metrics & Finances';

  @override
  String get continueWithGoogle => 'Continue with Google Workspace';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get termsNotice =>
      'By continuing, you agree to Docentia\'s Terms of Service and Privacy Policy.';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get greetingSubtitle => 'Welcome to your educator dashboard';

  @override
  String get activeCoursesSummary => 'active courses';

  @override
  String get activeStudentsSummary => 'total students';

  @override
  String get activeCoursesCard => 'Active Courses';

  @override
  String get studentsCard => 'Students';

  @override
  String get monthlyIncomeCard => 'Monthly Income';

  @override
  String get todaysCoursesTitle => 'Today\'s Courses';

  @override
  String get newCourseBtn => 'New Course';

  @override
  String get noCoursesTodayTitle => 'No classes scheduled for today';

  @override
  String get noCoursesTodayDesc =>
      'Take this time to prepare teaching materials or review pending student evaluations.';

  @override
  String get createFirstCourseBtn => 'Create my first course';

  @override
  String get financeTitle => 'Stats & Finance';

  @override
  String get currentMonthTab => 'Current Month';

  @override
  String get previousMonthTab => 'Previous Month';

  @override
  String get allPeriodTab => 'All Time';

  @override
  String get collectedIncome => 'Collected Income';

  @override
  String get pendingCollect => 'pending';

  @override
  String get operatingExpenses => 'Operating Expenses';

  @override
  String get deductibleRecords => 'deductible records';

  @override
  String get netProfit => 'Net Profit';

  @override
  String get realtimeBalance => 'Real-time balance';

  @override
  String get financialDistribution => 'Financial Breakdown';

  @override
  String get netMargin => 'Net margin';

  @override
  String get incomeLabel => 'Income';

  @override
  String get expensesLabel => 'Expenses';

  @override
  String get expenseDetails => 'Recorded Expenses Details';

  @override
  String get addExpenseBtn => 'Record Expense';

  @override
  String get noExpensesPeriod => 'No expenses recorded in this period.';

  @override
  String get registerExpenseTitle => 'Record Teacher Expense';

  @override
  String get profileTitle => 'Teacher Profile';

  @override
  String get personalizationTitle => 'Personalization';

  @override
  String get personalizationDesc =>
      'Choose the main application color. Semantic colors (attendance, payments, and alerts) remain untouched.';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageDesc => 'Select the application language.';

  @override
  String get spanishLanguage => 'Español';

  @override
  String get englishLanguage => 'English';

  @override
  String get themeModeTitle => 'Visual Theme';

  @override
  String get themeModeDesc =>
      'Switch between light and dark modes to adapt the display to your environment.';

  @override
  String get lightMode => 'Light';

  @override
  String get darkMode => 'Dark';

  @override
  String get systemMode => 'System';

  @override
  String get editProfileData => 'Edit Profile';

  @override
  String get signOut => 'Sign Out';

  @override
  String get linkedWith => 'Account linked with';

  @override
  String get courseDetailTitle => 'Course Details';

  @override
  String get addStudentBtn => '+ Add Student';

  @override
  String get attendanceRecordBtn => 'Attendance History';

  @override
  String get studentListTitle => 'Student list';

  @override
  String get filterAll => 'All';

  @override
  String get filterPending => 'Pending';

  @override
  String get courseChannelTitle => 'Course Channel';

  @override
  String get studentsAndTutorsConnected => 'students and tutors connected';

  @override
  String get broadcastBtn => 'Broadcast';

  @override
  String get editCourseTitle => 'Edit Course';

  @override
  String get createCourseTitle => 'Create New Course';

  @override
  String get courseNameLabel => 'Course Name *';

  @override
  String get sessionsLabel => 'Total Sessions *';

  @override
  String get maxCapacityLabel => 'Max Capacity *';

  @override
  String get classDaysLabel => 'Class Days (at least 1) *';

  @override
  String get startTimeLabel => 'Start Time *';

  @override
  String get endTimeLabel => 'End Time *';

  @override
  String get classScheduleLabel => 'Class schedule';

  @override
  String get monthlyCostLabel => 'Monthly Fee (\$) *';

  @override
  String get paymentScheduleLabel => 'Billing Schedule';

  @override
  String get scheduleFirstHalf => 'First Half (Day 1-15)';

  @override
  String get scheduleEndOfMonth => 'End of Month (Day 25-30)';

  @override
  String get chooseIconLabel => 'Select Course Icon';

  @override
  String get deleteCourseBtn => 'Delete Course';

  @override
  String get studentDetailTitle => 'Student Record';

  @override
  String get tutorInfoTitle => 'Tutor information';

  @override
  String get sendWhatsAppBtn => 'Send WhatsApp to Tutor';

  @override
  String get attendanceSummaryTitle => 'Attendance Summary';

  @override
  String get monthlyFeesTitle => 'Fees & Payments';

  @override
  String get addFeeBtn => '+ Generate Fee';

  @override
  String get deactivateStudentBtn => 'Deactivate Student';

  @override
  String get calendarTitle => 'Activity Calendar';

  @override
  String get newEventBtn => '+ New Event';

  @override
  String get allFilter => 'All';

  @override
  String get classesFilter => 'Classes';

  @override
  String get eventsFilter => 'Events';

  @override
  String get paymentsFilter => 'Due Dates';

  @override
  String get noEventsDay => 'No events or classes scheduled for this date.';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get summarySubtitle => 'Here is a summary of your courses.';

  @override
  String get activeCourseSingular => 'active course';

  @override
  String get activeCoursePlural => 'active courses';

  @override
  String get studentSingular => 'student';

  @override
  String get studentPlural => 'students';

  @override
  String get pendingPaymentSingular => 'pending payment';

  @override
  String get pendingPaymentPlural => 'pending payments';

  @override
  String get summaryCardStudents => 'Students';

  @override
  String get summaryCardActiveCourses => 'Active courses';

  @override
  String get summaryCardIncome => 'Monthly Revenue';

  @override
  String get noCoursesYet => 'You don\'t have any courses yet';

  @override
  String get noCoursesYetDesc =>
      'Create your first course to start enrolling students and keeping track of them.';

  @override
  String get viewAllCourses => 'View all courses';

  @override
  String ofTotal(int total) {
    return 'of $total';
  }

  @override
  String get accept => 'Accept';

  @override
  String get required => 'Required';

  @override
  String errorWithDetail(String detail) {
    return 'Error: $detail';
  }

  @override
  String get courseFallback => 'Course';

  @override
  String get studentFallback => 'Student';

  @override
  String get teacherFallback => 'Teacher';

  @override
  String yearsOld(int age) {
    return '$age years';
  }

  @override
  String get duePrefix => 'Due';

  @override
  String get paidStatus => 'Paid';

  @override
  String get overdueStatus => 'Overdue';

  @override
  String get pendingStatus => 'Pending';

  @override
  String get upcomingStatus => 'Due soon';

  @override
  String get paymentUpToDate => 'Up to date';

  @override
  String get noFeeStatus => 'No fee';

  @override
  String get allStudentsCurrent => 'All students are up to date';

  @override
  String get presentStatus => 'Present';

  @override
  String get lateStatus => 'Late';

  @override
  String get absentStatus => 'Absent';

  @override
  String get excusedStatus => 'Excused';

  @override
  String get excusedNoteFallback => 'Excused';

  @override
  String get unmarkedStatus => 'Unmarked';

  @override
  String get notRecorded => 'Not recorded';

  @override
  String get register => 'Save';

  @override
  String get perMonth => 'month';

  @override
  String get enrolledWord => 'enrolled';

  @override
  String get appVersion => 'Docentia v1.0.0';

  @override
  String get loginShortSubtitle =>
      'Academic management and attendance tracking for educators.';

  @override
  String get continueWithGoogleShort => 'Continue with Google';

  @override
  String get termsPrefix => 'By continuing, you accept our';

  @override
  String get termsLink => 'Terms and Conditions';

  @override
  String get privacyLink => 'Privacy Policy';

  @override
  String get whatsappPhone => 'WhatsApp / Phone';

  @override
  String get biography => 'Biography';

  @override
  String get myCourses => 'My Courses';

  @override
  String get courseFee => 'Course fee';

  @override
  String get noCoursesManageDesc =>
      'Create your first course to start managing students, attendance, and payments.';

  @override
  String get selectStartTime => 'Select start time';

  @override
  String get selectEndTime => 'Select end time';

  @override
  String get selectAtLeastOneDay => 'Please select at least one class day.';

  @override
  String courseUpdatedSuccess(String name) {
    return 'Course \"$name\" updated successfully';
  }

  @override
  String courseCreatedSuccess(String name) {
    return 'Course \"$name\" created successfully';
  }

  @override
  String get deleteCourseConfirmTitle => 'Delete this course?';

  @override
  String deleteCourseConfirmBody(String name) {
    return 'You are about to delete the course \"$name\". The course will be deactivated and this cannot be undone.';
  }

  @override
  String get yesDeleteCourse => 'Yes, delete course';

  @override
  String courseDeletedSuccess(String name) {
    return 'Course \"$name\" deleted.';
  }

  @override
  String get courseNameHint => 'E.g. Advanced English B2';

  @override
  String get courseNameRequired => 'Name is required';

  @override
  String get cannotSaveAttendanceNotClassDay =>
      'Attendance cannot be saved: today is not a class day for this course.';

  @override
  String attendanceSaved(int count) {
    return 'Attendance saved ($count present)';
  }

  @override
  String get courseOptions => 'Course options';

  @override
  String get notClassDayBanner =>
      'No class today. Attendance is only available on class days.';

  @override
  String get addStudentShort => 'Add student';

  @override
  String get attendanceLog => 'Attendance log';

  @override
  String attendanceStudentOf(int current, int total) {
    return '$current of $total';
  }

  @override
  String get noStudentsForAttendance => 'Add students to take attendance.';

  @override
  String get attendanceRollComplete => 'Attendance taken successfully';

  @override
  String get attendanceDaySummary => 'Daily summary';

  @override
  String get allStudentsMarkedToday =>
      'Every student already has attendance for today';

  @override
  String get noStudentsInCourse =>
      'No students are enrolled in this course yet';

  @override
  String sessionOf(int current, int total) {
    return 'Session $current of $total';
  }

  @override
  String get todayAttendance => 'Today, Attendance';

  @override
  String get enrolledLabel => 'Enrolled';

  @override
  String get activeLabel => 'Active';

  @override
  String get courseActiveBadge => 'Active';

  @override
  String get presentsLabel => 'Present';

  @override
  String get latesLabel => 'Late';

  @override
  String get absencesLabel => 'Absences';

  @override
  String get spotsLabel => 'Seats';

  @override
  String ofCapacity(int capacity) {
    return 'Of $capacity';
  }

  @override
  String get studentRegisteredSuccess => 'Student registered successfully';

  @override
  String get addStudentTitle => 'Add Student';

  @override
  String addStudentDesc(String course) {
    return 'Enter the details to enroll the student in $course.';
  }

  @override
  String get firstNamesLabel => 'First name *';

  @override
  String get firstNameHint => 'E.g. Camila';

  @override
  String get lastNamesLabel => 'Last name *';

  @override
  String get lastNameHint => 'E.g. Morales Díaz';

  @override
  String get ageLabel => 'Age';

  @override
  String get relationshipLabel => 'Relationship';

  @override
  String get relationshipMother => 'Mother';

  @override
  String get relationshipFather => 'Father';

  @override
  String get relationshipTutor => 'Tutor';

  @override
  String get tutorNameLabel => 'Tutor name';

  @override
  String get tutorNameHint => 'E.g. Patricia Díaz';

  @override
  String get tutorPhoneRequiredLabel => 'Mobile phone (WhatsApp) *';

  @override
  String get phoneRequiredWhatsapp => 'Phone is required for WhatsApp';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'tutor@example.com';

  @override
  String get tutorFallback => 'Tutor';

  @override
  String get noTutorPhone => 'This student has no guardian phone on file';

  @override
  String whatsappProgressMessage(String tutor, String student) {
    return 'Hello $tutor, I\'m writing from Docentia to update you on $student\'s progress.';
  }

  @override
  String get whatsappOpenError => 'WhatsApp could not be opened on this device';

  @override
  String get deactivateStudentTitle => 'Deactivate this student?';

  @override
  String deactivateStudentBody(String name) {
    return '$name will leave the active course list, but attendance and payments will be kept.';
  }

  @override
  String get studentDeactivated => 'Student deactivated. History kept.';

  @override
  String get confirmDeactivate => 'Confirm deactivation';

  @override
  String get newMonthlyFee => 'Prorated fee';

  @override
  String get feeConfigHelp =>
      'For students who return mid-cycle. Only the days left until the next automatic charge are billed.';

  @override
  String get returnDateLabel => 'Return date';

  @override
  String get nextChargeDate => 'Next automatic charge';

  @override
  String remainingDaysCount(int days) {
    return '$days days remaining';
  }

  @override
  String proratedBreakdown(int remaining, int cycle) {
    return '$remaining of $cycle days in the cycle';
  }

  @override
  String get proratedBadge => 'Prorated';

  @override
  String get proratedOnBillingDay =>
      'Today is this course\'s billing day. The monthly fee is generated automatically.';

  @override
  String proratedFeeCreated(int days) {
    return 'Prorated fee created for $days days.';
  }

  @override
  String get proratedAlreadyExists =>
      'A prorated fee until the next charge already exists.';

  @override
  String get createProratedFee => 'Create prorated fee';

  @override
  String get addProratedFee => '+ Prorated';

  @override
  String get monthAndYear => 'Month and year:';

  @override
  String get dueDateField => 'Due date:';

  @override
  String get monthStart => 'Start of month';

  @override
  String get monthStartDay1 => 'Day 1 of the corresponding month';

  @override
  String get monthEnd => 'End of month';

  @override
  String get monthEndLastDay => 'Last valid day (includes leap years)';

  @override
  String get calculatedDate => 'Calculated date:';

  @override
  String get amountToCharge => 'Amount due:';

  @override
  String get createFee => 'Create fee';

  @override
  String feeCreated(String period) {
    return 'Fee created for $period.';
  }

  @override
  String get feeAlreadyExists =>
      'A fee for this month is already registered for this student and course.';

  @override
  String get modifyDueDate => 'Change due date';

  @override
  String changeDueOption(String period) {
    return 'Change the due date option for the $period fee:';
  }

  @override
  String get monthStartDay1Short => 'Start of month (Day 1)';

  @override
  String get monthEndLastDayShort => 'End of month (last day)';

  @override
  String resultingDueDate(String date) {
    return 'Resulting due date: $date';
  }

  @override
  String dueDateUpdated(String date) {
    return 'Due date updated to $date';
  }

  @override
  String get update => 'Update';

  @override
  String get confirmPayment => 'Confirm payment';

  @override
  String get reviewPaymentData => 'Review the payment you are about to record:';

  @override
  String get studentColon => 'Student:';

  @override
  String get courseColon => 'Course:';

  @override
  String get monthlyFeeColon => 'Monthly fee:';

  @override
  String get feeConceptLabel => 'Item';

  @override
  String get monthlyFeeConcept => 'Monthly fee';

  @override
  String get courseMonthlyFee => 'Course monthly fee';

  @override
  String get periodLabel => 'Period';

  @override
  String get paymentDateColon => 'Payment date:';

  @override
  String get amountToPay => 'Amount to pay:';

  @override
  String paymentConfirmed(String amount, String student) {
    return 'Payment of $amount confirmed for $student';
  }

  @override
  String get studentNotFound => 'Student not found';

  @override
  String get regularStudent => 'Active student';

  @override
  String get deactivatedStudent => 'Deactivated';

  @override
  String get whatsappTutor => 'WhatsApp tutor';

  @override
  String get studentAttendance => 'Student attendance';

  @override
  String get realtimeRecord => 'Live record';

  @override
  String get classesLabel => 'Classes';

  @override
  String get attendancesLabel => 'Present';

  @override
  String get percentageLabel => 'Percentage';

  @override
  String get metricsError => 'Could not calculate metrics';

  @override
  String get tutorDataTitle => 'Tutor details';

  @override
  String get editTutorBtn => 'Edit';

  @override
  String get editTutorTitle => 'Edit tutor details';

  @override
  String get tutorUpdatedSuccess => 'Tutor details updated';

  @override
  String get editStudentTitle => 'Edit student details';

  @override
  String get studentUpdatedSuccess => 'Student details updated';

  @override
  String get emergencyContactTitle => 'Emergency contact';

  @override
  String get editEmergencyTitle => 'Edit emergency contact';

  @override
  String get emergencyUpdatedSuccess => 'Emergency contact updated';

  @override
  String get noEmergencyContact => 'No emergency contact';

  @override
  String get nameLabel => 'Name';

  @override
  String get mobilePhone => 'Mobile phone';

  @override
  String get secondaryPhone => 'Secondary phone';

  @override
  String get noFeesYet => 'No fees have been issued for this student yet.';

  @override
  String get generateMonthly => 'Generate monthly fee';

  @override
  String dueOn(String date) {
    return 'Due: $date';
  }

  @override
  String get startShort => 'Start';

  @override
  String get confirmPaymentShort => 'Confirm payment';

  @override
  String get sendFeeBtn => 'Send';

  @override
  String get paymentsLoadError => 'Could not load payments';

  @override
  String get swipeMarkHint => 'Swipe: ⟵ Absent | Present ⟶';

  @override
  String get swipeCorrectHint => 'Swipe the other way to correct';

  @override
  String get classDaysOnly => 'Class days only';

  @override
  String get noteTitle => 'Note / Excuse';

  @override
  String get noteReasonLabel => 'Absence reason / note';

  @override
  String get noteHint => 'E.g. Medical appointment, family leave...';

  @override
  String get viewNote => 'View note';

  @override
  String get attendanceHistoryTitle => 'Attendance log';

  @override
  String get noSessionsYet => 'No classes recorded yet';

  @override
  String get noSessionsDesc =>
      'When you save attendance for a class, its date, time, and the list of present and absent students will be kept here.';

  @override
  String historyLoadError(String detail) {
    return 'Could not load history: $detail';
  }

  @override
  String presentsCount(int count) {
    return 'Present: $count';
  }

  @override
  String latesCount(int count) {
    return 'Late: $count';
  }

  @override
  String absencesCount(int count) {
    return 'Absences: $count';
  }

  @override
  String presentsHeader(int count) {
    return 'Present — $count';
  }

  @override
  String get noPresentsRecorded => 'No students marked present';

  @override
  String absencesHeader(int count) {
    return 'Absences — $count';
  }

  @override
  String get noAbsences => 'No absences in this class';

  @override
  String get financeStatsTitle => 'Financial stats';

  @override
  String get allYearTab => 'All year';

  @override
  String get netProfitFormula => 'Net profit (income − expenses)';

  @override
  String marginLabel(String percent) {
    return 'Margin: $percent%';
  }

  @override
  String collectedWithAmount(String amount) {
    return 'Collected: $amount';
  }

  @override
  String expensesWithAmount(String amount) {
    return 'Expenses: $amount';
  }

  @override
  String get teacherExpenses => 'Teacher expenses';

  @override
  String get expenseDescriptionLabel => 'Expense description';

  @override
  String get amountDollarLabel => 'Amount (\$)';

  @override
  String get categoryMaterials => 'Materials and books';

  @override
  String get categorySoftware => 'Software and licenses';

  @override
  String get categorySupplies => 'Classroom supplies';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryMisc => 'Miscellaneous';

  @override
  String get newSchoolEvent => 'New school event';

  @override
  String get eventTitleLabel => 'Event title *';

  @override
  String get eventTitleHint => 'E.g. Midterm exam / Project deadline';

  @override
  String get activityType => 'Activity type';

  @override
  String get eventTypeExam => 'Exam';

  @override
  String get eventTypeProject => 'Project';

  @override
  String get eventTypeMeeting => 'Parent meeting';

  @override
  String get eventTypeHoliday => 'Holiday';

  @override
  String get eventTypeSpecial => 'Special';

  @override
  String get associatedCourse => 'Related course';

  @override
  String get allCoursesGeneral => 'General / All courses';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Time';

  @override
  String get locationLabel => 'Location / Room / Link (optional)';

  @override
  String get locationHint => 'E.g. Room 3B, Lab, or Google Meet';

  @override
  String get descriptionInstructionsLabel => 'Description / Instructions *';

  @override
  String get descriptionHint =>
      'Activity details, topics to assess, or required materials...';

  @override
  String get extraEmailsLabel => 'Additional guardian emails (optional)';

  @override
  String get extraEmailsHint => 'guardian@example.com, office@school.edu';

  @override
  String get eventTitleRequired => 'The event title is required.';

  @override
  String get eventDescriptionRequired =>
      'Please enter a description for the event.';

  @override
  String eventSaved(String title) {
    return 'Event \"$title\" added to the calendar';
  }

  @override
  String get saveEvent => 'Save event';

  @override
  String get sendEventToParents => 'Send event to parents';

  @override
  String bccPrivacyNotice(int count) {
    return 'The email will be prepared for $count guardians using hidden copy (BCC) to protect their privacy.';
  }

  @override
  String get subjectPrefix => 'Subject:';

  @override
  String get noticeCopied => 'Notice copied to the clipboard';

  @override
  String get copyText => 'Copy text';

  @override
  String get openMail => 'Open mail';

  @override
  String get noMailClient => 'No mail app was found. The message was copied.';

  @override
  String get calendarClassesTitle => 'Class and event calendar';

  @override
  String get schoolEvents => 'School events';

  @override
  String get noSchoolEvents => 'No school events recorded';

  @override
  String get noSchoolEventsDesc =>
      'You can add exams, parent meetings, or activities with the \"+ New event\" button.';

  @override
  String get createEvent => '+ Create event';

  @override
  String get coursePaymentsTitle => 'Course payments and fees';

  @override
  String get noDueDatesToday => 'No fees due today';

  @override
  String get noDueDatesDesc =>
      'There are no payments with a due date on this day.';

  @override
  String get scheduledClasses => 'Scheduled classes';

  @override
  String get noClassesThisDay => 'No classes scheduled for this day';

  @override
  String get noClassesThisDayDesc =>
      'Select another day in the weekly calendar to see the schedule.';

  @override
  String get deleteEvent => 'Delete event';

  @override
  String get eventDeleted => 'School event deleted';

  @override
  String get notifyParents => 'Notify parents';

  @override
  String feeReminder(String name) {
    return 'Fee reminder: $name';
  }

  @override
  String feeScheduleLine(String schedule, String amount) {
    return 'Scheduled billing date: $schedule · Fee: $amount';
  }

  @override
  String get monthStartRange => 'Start of month (day 1–10)';

  @override
  String get monthEndDay30 => 'End of month (day 30)';

  @override
  String get attendanceAction => 'Attendance';

  @override
  String classesTabCount(int count) {
    return 'Classes ($count)';
  }

  @override
  String eventsTabCount(int count) {
    return 'Events ($count)';
  }

  @override
  String paymentsTabCount(int count) {
    return 'Payments ($count)';
  }

  @override
  String schoolNoticeSubject(String title, String date) {
    return '[Docentia] School notice: $title ($date)';
  }

  @override
  String schoolNoticeBody(String title, String date, String schedule,
      String location, String description, String teacher) {
    return 'Dear parents and guardians:\n\nThis school notice is to inform you of the following activity scheduled in Docentia:\n• Event: $title\n• Date: $date\n• Time: $schedule$location\n• Description: $description\n\nThank you for your support and punctual attendance.\n\nSincerely,\n$teacher\nDocentia - Academic Platform';
  }

  @override
  String get principalTeacher => 'Lead teacher';

  @override
  String locationLine(String place) {
    return '\n• Location: $place';
  }

  @override
  String attendancePctShort(int percent) {
    return '$percent% att.';
  }

  @override
  String excusedCompact(int count) {
    return '$count exc.';
  }

  @override
  String get completeProfileTitle => 'Personalize your account';

  @override
  String get completeProfileSubtitle =>
      'Your account does not include a name. Complete your profile to continue.';

  @override
  String get completeProfileNameLabel => 'Name *';

  @override
  String get completeProfileNameHint => 'E.g. Ana García';

  @override
  String get completeProfilePhoneLabel => 'Phone / WhatsApp';

  @override
  String get completeProfilePhoneHint => '+1 555 123 4567';

  @override
  String get completeProfileBioLabel => 'Biography';

  @override
  String get completeProfileBioHint => 'Tell us about your teaching work';

  @override
  String get completeProfileContinue => 'Continue';

  @override
  String get completeProfilePhotoHint => 'Add photo';

  @override
  String get completeProfileNameRequired => 'Enter your name';

  @override
  String get completeProfileNameInvalid => 'Use your name, not an email';

  @override
  String get completeProfileGallery => 'Choose from gallery';

  @override
  String get completeProfileCamera => 'Take a photo';

  @override
  String get loginWelcomeTagline => 'Welcome to Docentia — we do the real work';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginForgotPassword => 'Forgot your password?';

  @override
  String get loginSignIn => 'Sign in';

  @override
  String get loginOrSeparator => 'or';

  @override
  String get loginEmailRequired => 'Enter your email';

  @override
  String get loginEmailInvalid => 'Enter a valid email';

  @override
  String get loginPasswordRequired => 'Enter your password';

  @override
  String get loginPasswordTooShort => 'Use at least 6 characters';

  @override
  String get loginResetEmailRequired => 'Enter your email to reset it';

  @override
  String get loginResetPasswordSent =>
      'We sent you an email to reset your password.';
}
