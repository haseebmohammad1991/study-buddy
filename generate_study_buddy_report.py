from __future__ import annotations

import html
import zipfile
from pathlib import Path


OUT = Path("Study_Buddy_Project_Report.docx")


def esc(text: str) -> str:
    return html.escape(text, quote=False)


def run_text(text: str, bold: bool = False, italic: bool = False) -> str:
    props = ""
    if bold or italic:
        parts = []
        if bold:
            parts.append("<w:b/>")
        if italic:
            parts.append("<w:i/>")
        props = f"<w:rPr>{''.join(parts)}</w:rPr>"
    return f"<w:r>{props}<w:t xml:space=\"preserve\">{esc(text)}</w:t></w:r>"


def paragraph(
    text: str = "",
    style: str | None = None,
    align: str | None = None,
    bold: bool = False,
    italic: bool = False,
    spacing_after: int = 160,
) -> str:
    props = []
    if style:
        props.append(f"<w:pStyle w:val=\"{style}\"/>")
    if align:
        props.append(f"<w:jc w:val=\"{align}\"/>")
    props.append(f"<w:spacing w:after=\"{spacing_after}\"/>")
    ppr = f"<w:pPr>{''.join(props)}</w:pPr>"
    return f"<w:p>{ppr}{run_text(text, bold=bold, italic=italic)}</w:p>"


def heading(text: str, level: int = 1) -> str:
    return paragraph(text, style=f"Heading{level}", spacing_after=180)


def bullet(text: str) -> str:
    return paragraph(f"• {text}", spacing_after=90)


def page_break() -> str:
    return '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'


def toc_field() -> str:
    return """
    <w:p>
      <w:pPr><w:pStyle w:val="TOCHeading"/><w:spacing w:after="160"/></w:pPr>
      <w:r><w:t>Table of Contents</w:t></w:r>
    </w:p>
    <w:p>
      <w:r><w:fldChar w:fldCharType="begin"/></w:r>
      <w:r><w:instrText xml:space="preserve"> TOC \\o "1-3" \\h \\z \\u </w:instrText></w:r>
      <w:r><w:fldChar w:fldCharType="separate"/></w:r>
      <w:r><w:t>Right-click here in Microsoft Word and select Update Field to generate the table of contents.</w:t></w:r>
      <w:r><w:fldChar w:fldCharType="end"/></w:r>
    </w:p>
    """


def simple_table(rows: list[list[str]], widths: list[int] | None = None) -> str:
    widths = widths or [4500 for _ in rows[0]]
    grid = "".join(f'<w:gridCol w:w="{w}"/>' for w in widths)
    body = []
    for row in rows:
        cells = []
        for idx, cell in enumerate(row):
            cells.append(
                f"""
                <w:tc>
                  <w:tcPr><w:tcW w:w="{widths[idx]}" w:type="dxa"/></w:tcPr>
                  {paragraph(cell, spacing_after=60)}
                </w:tc>
                """
            )
        body.append(f"<w:tr>{''.join(cells)}</w:tr>")
    return f"""
    <w:tbl>
      <w:tblPr>
        <w:tblStyle w:val="TableGrid"/>
        <w:tblW w:w="0" w:type="auto"/>
      </w:tblPr>
      <w:tblGrid>{grid}</w:tblGrid>
      {''.join(body)}
    </w:tbl>
    """


def placeholder_box(title: str, caption: str) -> str:
    return simple_table(
        [[f"{title}\n\n[Insert screenshot here]\n\n{caption}"]],
        widths=[9000],
    )


def document_body() -> str:
    parts: list[str] = []

    parts += [
        paragraph("Study Buddy", style="Title", align="center", spacing_after=220),
        paragraph(
            "A Student Productivity Android Application Developed Using Flutter",
            style="Subtitle",
            align="center",
            spacing_after=420,
        ),
        paragraph("Project Report", align="center", bold=True, spacing_after=520),
        simple_table(
            [
                ["Student Name", "[Enter Student Name]"],
                ["Roll Number", "[Enter Roll Number]"],
                ["Department", "[Enter Department Name]"],
                ["University Name", "[Enter University Name]"],
                ["Submission Date", "[Enter Submission Date]"],
            ],
            widths=[2800, 6200],
        ),
        paragraph("", spacing_after=600),
        paragraph(
            "Submitted in partial fulfillment of the requirements for the course/project evaluation.",
            align="center",
            italic=True,
        ),
        page_break(),
    ]

    parts += [
        heading("Certificate", 1),
        paragraph(
            "This is to certify that the project report entitled “Study Buddy” has been prepared and submitted by [Enter Student Name], Roll Number [Enter Roll Number], of the Department of [Enter Department Name], [Enter University Name]. The project has been completed under academic supervision and is submitted for evaluation as part of the university project requirements.",
        ),
        paragraph(
            "The work presented in this report is original to the best of the student’s knowledge and demonstrates the design and development of a Flutter-based Android application for student productivity management.",
        ),
        paragraph("", spacing_after=420),
        simple_table(
            [
                ["Supervisor / Teacher Signature", "____________________________"],
                ["Department Stamp", "____________________________"],
                ["Date", "____________________________"],
            ],
            widths=[3600, 5400],
        ),
        page_break(),
        heading("Acknowledgement", 1),
        paragraph(
            "The completion of the Study Buddy project report would not have been possible without the guidance, support, and encouragement of several individuals. The student expresses sincere gratitude to the respected teacher and project supervisor for valuable guidance, constructive feedback, and continuous academic support throughout the development process.",
        ),
        paragraph(
            "The student also thanks the department for providing the learning environment and resources required to complete the project. Appreciation is extended to classmates, friends, and family members for their motivation, suggestions, and assistance during testing and review. Their support contributed significantly to the successful completion of this project.",
        ),
        page_break(),
        heading("Abstract", 1),
        paragraph(
            "Study Buddy is a Flutter-based Android application designed to support students in managing academic activities in a simple and organized manner. Many students face difficulties in tracking class schedules, assignment deadlines, study notes, examination dates, and focused study sessions using separate tools. This project addresses that problem by presenting a single mobile application that combines essential productivity features in one clean interface.",
        ),
        paragraph(
            "The application includes a timetable manager, assignment tracker, notes system, exam countdown timer, Pomodoro-based focus mode, and a daily study streak system. The user interface follows Material 3 design principles with a calm visual theme, responsive layout, light and dark mode support, and easy navigation through a bottom navigation bar. The project uses Flutter and Dart for cross-platform mobile development, while local storage concepts such as Hive are used to maintain app data on the device without requiring a backend server.",
        ),
        paragraph(
            "The outcome of the project is a functional Android application that improves student organization, encourages regular study habits, and provides a distraction-free environment for academic planning. Study Buddy demonstrates practical knowledge of mobile app design, user interface development, local data handling, and modular software structure.",
        ),
        page_break(),
        toc_field(),
        page_break(),
    ]

    parts += [
        heading("CHAPTER 1: INTRODUCTION", 1),
        heading("1.1 Project Background", 2),
        paragraph(
            "Students are required to manage several academic responsibilities at the same time, including attending classes, completing assignments, preparing notes, tracking examinations, and maintaining consistent study routines. In many cases, these responsibilities are managed manually through notebooks, reminders, messaging applications, or separate digital tools. This scattered approach often leads to missed deadlines, poor time management, and reduced productivity.",
        ),
        paragraph(
            "Study Buddy is developed as a student productivity application that brings the most common academic planning tools into one mobile interface. The application is designed for Android using Flutter, which enables the creation of a smooth, modern, and responsive user interface. The project focuses on usability, simplicity, and practical academic value.",
        ),
        heading("1.2 Problem Statement", 2),
        paragraph(
            "Students often lack a centralized and easy-to-use tool for managing academic schedules, assignment deadlines, notes, exam preparation, and focused study sessions. Existing methods may be fragmented, difficult to maintain, or overloaded with unnecessary features. This creates a need for a lightweight mobile application that helps students organize their daily academic activities efficiently.",
        ),
        heading("1.3 Objectives", 2),
        bullet("To design and develop a Flutter-based Android productivity application for students."),
        bullet("To provide a timetable manager for organizing daily and weekly classes."),
        bullet("To allow students to track assignments with due dates and completion status."),
        bullet("To create a notes section for saving important academic content locally."),
        bullet("To display exam countdowns for better preparation planning."),
        bullet("To include a Pomodoro focus mode for structured study sessions."),
        bullet("To encourage consistency through a daily study streak system."),
        heading("1.4 Scope of the Application", 2),
        paragraph(
            "The scope of Study Buddy is limited to local student productivity management. The application does not require a remote backend or cloud account. It is suitable for students who want a simple academic planner on their Android device. The system includes timetable management, tasks, notes, exam countdowns, focus sessions, and streak-based motivation. Future versions may include cloud synchronization, advanced notifications, and AI-based study suggestions.",
        ),
        page_break(),
    ]

    parts += [
        heading("CHAPTER 2: LITERATURE / EXISTING SYSTEM", 1),
        heading("2.1 Existing Study Applications", 2),
        paragraph(
            "Several productivity applications are available for students, including calendar applications, task managers, note-taking tools, and Pomodoro timers. These applications are useful in specific areas, but they often focus on only one activity. For example, a calendar application may manage classes but may not provide a notes system or Pomodoro timer. Similarly, a note-taking application may not track assignments or exam countdowns.",
        ),
        heading("2.2 Limitations of Existing Systems", 2),
        bullet("Many applications require account creation or internet access for full functionality."),
        bullet("Some productivity tools are too complex for basic student use."),
        bullet("Important student features are often distributed across multiple applications."),
        bullet("Existing tools may not provide a study streak or academic motivation system."),
        bullet("Users may experience distraction due to unnecessary features and notifications."),
        heading("2.3 Improvements Provided by Study Buddy", 2),
        paragraph(
            "Study Buddy improves upon existing systems by combining essential academic tools in a single application. The app is local-first, lightweight, and designed specifically for students. It provides a calm interface, clear navigation, and practical modules that directly support academic planning. The inclusion of focus mode and study streaks also encourages consistent study behavior without overwhelming the user.",
        ),
        page_break(),
    ]

    parts += [
        heading("CHAPTER 3: SYSTEM DESIGN", 1),
        heading("3.1 App Architecture Overview", 2),
        paragraph(
            "Study Buddy follows a modular architecture in which the application is divided into models, screens, providers, services, and reusable widgets. This structure separates user interface components from data handling and application logic. Flutter widgets are used to construct the interface, while providers manage state changes. Local services handle persistent data storage and notification-related operations.",
        ),
        simple_table(
            [
                ["Layer", "Description"],
                ["Screens", "Display user interfaces such as Home, Timetable, Tasks, Notes, Exams, and Focus."],
                ["Providers", "Manage application state and connect UI screens with local data operations."],
                ["Models", "Represent structured data such as assignments, notes, timetable entries, and exams."],
                ["Services", "Handle local storage and notification operations."],
                ["Widgets", "Reusable UI elements such as cards, labels, buttons, and layout components."],
            ],
            widths=[2400, 6600],
        ),
        heading("3.2 Modules Description", 2),
        heading("3.2.1 Timetable Module", 3),
        paragraph(
            "The timetable module allows students to manage daily or weekly class schedules. Each timetable entry contains subject information, location, weekday, and time slot. The module presents classes in a clean card-based format so that students can quickly view their academic day.",
        ),
        heading("3.2.2 Tasks Module", 3),
        paragraph(
            "The tasks module tracks assignments and academic work. Each task includes a title, subject, due date, and status. The interface highlights overdue assignments and supports completion marking, helping students prioritize urgent work.",
        ),
        heading("3.2.3 Notes Module", 3),
        paragraph(
            "The notes module provides a space for students to create and edit study notes. Notes include a title, subject, body text, and last updated date. The design allows quick scanning of note previews and supports a simple editor screen.",
        ),
        heading("3.2.4 Exam Countdown Module", 3),
        paragraph(
            "The exam module records upcoming examinations and displays countdown information. It helps students stay aware of remaining preparation time and view the nearest exam directly from the home screen.",
        ),
        heading("3.2.5 Pomodoro Focus Module", 3),
        paragraph(
            "The focus module provides a Pomodoro timer with focus and break cycles. The interface contains a large timer display and simple controls for starting, pausing, resetting, and completing a session. This module encourages distraction-free study.",
        ),
        heading("3.2.6 Daily Study Streak System", 3),
        paragraph(
            "The streak system records daily study activity and motivates students through badges and progress indicators. It uses gamification principles in a subtle way to encourage regular academic effort.",
        ),
        heading("3.3 Simple Application Flow", 2),
        bullet("The user opens the Study Buddy application."),
        bullet("The Home screen summarizes current academic status, including timetable, streak, and nearest exam."),
        bullet("The user navigates through the bottom navigation bar to access timetable, tasks, notes, exams, or focus mode."),
        bullet("The user adds or updates local information such as assignments, notes, and exams."),
        bullet("The focus mode can be used for structured study sessions, which supports streak progress."),
        page_break(),
    ]

    parts += [
        heading("CHAPTER 4: IMPLEMENTATION", 1),
        heading("4.1 Flutter Framework", 2),
        paragraph(
            "The Study Buddy application is implemented using Flutter, an open-source UI toolkit for building mobile applications from a single codebase. Flutter uses the Dart programming language and provides a rich widget system for constructing responsive and high-performance interfaces. The project targets Android devices and can be built as an APK for testing.",
        ),
        heading("4.2 UI Design Approach", 2),
        paragraph(
            "The user interface follows Material 3 design principles. The design uses soft colors, rounded cards, clean typography, and sufficient spacing to create a calm study environment. The application supports both light and dark themes, allowing users to switch between modes according to their preference.",
        ),
        heading("4.3 Local Storage Concept", 2),
        paragraph(
            "The application uses the concept of local storage to save user data on the device. A local-first approach is suitable for this project because students can use the application without requiring constant internet access. Hive or SQLite can be used for this purpose; in this project, Hive-style local storage is used for lightweight data persistence.",
        ),
        heading("4.4 Screens Overview", 2),
        simple_table(
            [
                ["Screen", "Purpose"],
                ["Home", "Displays greeting, active streak, nearest exam, today’s timetable, and focus session shortcut."],
                ["Timetable", "Displays class schedule cards and allows timetable entries to be managed."],
                ["Tasks", "Displays assignments with status, due date, overdue highlighting, and search support."],
                ["Notes", "Displays study notes and opens a note editor for creating or updating notes."],
                ["Exams", "Displays upcoming exams with countdown labels."],
                ["Focus", "Displays a Pomodoro timer with calm full-screen timer controls."],
                ["Profile / Stats", "Displays study streak, progress cards, badges, and recent study activity."],
            ],
            widths=[2500, 6500],
        ),
        heading("4.5 Small Code Snippet Example", 2),
        paragraph(
            "The following small example shows the general idea of a reusable Flutter UI component. The full source code is not included in this report to maintain clarity and avoid unnecessary length.",
        ),
        paragraph(
            "class AppCard extends StatelessWidget {\n  final Widget child;\n  const AppCard({super.key, required this.child});\n\n  @override\n  Widget build(BuildContext context) {\n    return Card(\n      child: Padding(\n        padding: const EdgeInsets.all(16),\n        child: child,\n      ),\n    );\n  }\n}",
            style="CodeBlock",
            spacing_after=220,
        ),
        page_break(),
    ]

    parts += [
        heading("CHAPTER 5: RESULTS", 1),
        heading("5.1 Application Output", 2),
        paragraph(
            "The Study Buddy application was successfully built and tested as an Android application. The main screens are accessible through bottom navigation, and the interface provides a smooth and organized user experience. The application includes working modules for timetable management, assignment tracking, notes, exam countdowns, focus sessions, daily streaks, and theme switching.",
        ),
        heading("5.2 Feature Results", 2),
        bullet("The Home screen displays academic summary information clearly."),
        bullet("The Timetable screen shows daily schedule cards with subject and time details."),
        bullet("The Tasks screen displays pending and completed assignments with due dates."),
        bullet("The Notes screen allows users to view and edit study notes."),
        bullet("The Exams screen displays upcoming exams and countdown information."),
        bullet("The Focus screen provides a Pomodoro-style timer interface."),
        bullet("The Profile / Stats screen displays streaks, progress, and badges."),
        heading("5.3 Screenshots Placeholders", 2),
        placeholder_box("Figure 5.1: Home Screen", "Placeholder for Home dashboard screenshot."),
        paragraph("", spacing_after=120),
        placeholder_box("Figure 5.2: Timetable Screen", "Placeholder for Timetable screen screenshot."),
        paragraph("", spacing_after=120),
        placeholder_box("Figure 5.3: Tasks Screen", "Placeholder for Assignment Tracker screenshot."),
        paragraph("", spacing_after=120),
        placeholder_box("Figure 5.4: Notes Screen", "Placeholder for Notes system screenshot."),
        paragraph("", spacing_after=120),
        placeholder_box("Figure 5.5: Exams Screen", "Placeholder for Exam Countdown screen screenshot."),
        paragraph("", spacing_after=120),
        placeholder_box("Figure 5.6: Focus Mode Screen", "Placeholder for Pomodoro timer screenshot."),
        page_break(),
    ]

    parts += [
        heading("CHAPTER 6: CONCLUSION", 1),
        paragraph(
            "Study Buddy successfully demonstrates the design and development of a student productivity Android application using Flutter. The project addresses the common problem of academic disorganization by providing multiple useful tools in a single mobile app. The application includes timetable management, assignment tracking, notes, exam countdowns, Pomodoro focus mode, and a daily streak system.",
        ),
        paragraph(
            "The project achieved its objective of creating a clean, modern, and user-friendly productivity app for students. It also provided practical learning in Flutter development, UI/UX design, local storage concepts, modular architecture, and Android APK generation. The final application is suitable for demonstration, testing, and academic evaluation.",
        ),
        heading("6.1 Learning Outcomes", 2),
        bullet("Understanding of Flutter widgets and Material 3 interface design."),
        bullet("Experience in organizing a mobile application using clean folder structure."),
        bullet("Knowledge of local data storage concepts for mobile apps."),
        bullet("Practical understanding of Android build and APK generation."),
        bullet("Improved ability to design user-centered academic productivity tools."),
        page_break(),
    ]

    parts += [
        heading("CHAPTER 7: FUTURE SCOPE", 1),
        paragraph(
            "Although Study Buddy includes the core features required for student productivity, several improvements can be added in future versions to make the application more powerful and personalized.",
        ),
        bullet("Cloud synchronization can be added so users can access data across multiple devices."),
        bullet("AI-based study suggestions can recommend focus sessions, revision plans, and deadline priorities."),
        bullet("Multi-device support can allow seamless use on phones, tablets, and web platforms."),
        bullet("Notification improvements can provide smarter assignment and exam reminders."),
        bullet("Calendar integration can allow timetable and exam events to sync with external calendars."),
        bullet("Advanced analytics can show weekly study patterns and productivity trends."),
        page_break(),
    ]

    parts += [
        heading("APPENDICES", 1),
        heading("Appendix A: Screenshots", 2),
        paragraph(
            "This section is reserved for final application screenshots. Screenshots should be inserted after running the application on an Android device or emulator.",
        ),
        placeholder_box("Appendix Figure A.1: Light Mode Home Screen", "Insert screenshot here."),
        paragraph("", spacing_after=120),
        placeholder_box("Appendix Figure A.2: Dark Mode Focus Screen", "Insert screenshot here."),
        paragraph("", spacing_after=120),
        placeholder_box("Appendix Figure A.3: Assignment Tracker Screen", "Insert screenshot here."),
        heading("Appendix B: Tools and Technologies", 2),
        simple_table(
            [
                ["Technology", "Usage"],
                ["Flutter", "Mobile app UI and Android application development."],
                ["Dart", "Programming language used by Flutter."],
                ["Material 3", "Design system used for UI styling."],
                ["Hive / Local Storage", "Local persistence concept for app data."],
                ["Android APK", "Final build format for testing on Android phone."],
            ],
            widths=[2800, 6200],
        ),
        heading("Appendix C: Small Code Snippet", 2),
        paragraph(
            "Theme switching is an example of a small feature that improves user experience. It allows the application to switch between light and dark mode while keeping the interface comfortable for different environments.",
        ),
        paragraph(
            "ThemeMode get themeMode => _themeMode;\n\nFuture<void> toggleTheme() async {\n  _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;\n  notifyListeners();\n}",
            style="CodeBlock",
        ),
        page_break(),
        heading("REFERENCES", 1),
        paragraph("1. Flutter Documentation. https://docs.flutter.dev/"),
        paragraph("2. Dart Language Documentation. https://dart.dev/guides"),
        paragraph("3. Material Design Guidelines. https://m3.material.io/"),
        paragraph("4. Android Developers Documentation. https://developer.android.com/"),
        paragraph("5. Hive Documentation. https://docs.hivedb.dev/"),
    ]

    return "".join(parts)


def build_document_xml() -> str:
    return f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
 xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
 xmlns:o="urn:schemas-microsoft-com:office:office"
 xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
 xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
 xmlns:v="urn:schemas-microsoft-com:vml"
 xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
 xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
 xmlns:w10="urn:schemas-microsoft-com:office:word"
 xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
 xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
 xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
 xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
 xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
 xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
 mc:Ignorable="w14 wp14">
  <w:body>
    {document_body()}
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="1440" w:right="1260" w:bottom="1440" w:left="1260" w:header="708" w:footer="708" w:gutter="0"/>
      <w:cols w:space="708"/>
      <w:docGrid w:linePitch="360"/>
    </w:sectPr>
  </w:body>
</w:document>"""


def build_styles_xml() -> str:
    return """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
    <w:name w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:spacing w:line="276" w:lineRule="auto" w:after="160"/></w:pPr>
    <w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/><w:sz w:val="24"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Title">
    <w:name w:val="Title"/>
    <w:basedOn w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:jc w:val="center"/><w:spacing w:after="220"/></w:pPr>
    <w:rPr><w:b/><w:color w:val="1F4E79"/><w:sz w:val="48"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Subtitle">
    <w:name w:val="Subtitle"/>
    <w:basedOn w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:jc w:val="center"/><w:spacing w:after="220"/></w:pPr>
    <w:rPr><w:color w:val="5B6EE1"/><w:sz w:val="28"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="heading 1"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:keepNext/><w:spacing w:before="240" w:after="160"/><w:outlineLvl w:val="0"/></w:pPr>
    <w:rPr><w:b/><w:color w:val="1F4E79"/><w:sz w:val="32"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading2">
    <w:name w:val="heading 2"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:keepNext/><w:spacing w:before="180" w:after="120"/><w:outlineLvl w:val="1"/></w:pPr>
    <w:rPr><w:b/><w:color w:val="404B69"/><w:sz w:val="27"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading3">
    <w:name w:val="heading 3"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr><w:keepNext/><w:spacing w:before="120" w:after="100"/><w:outlineLvl w:val="2"/></w:pPr>
    <w:rPr><w:b/><w:color w:val="5B6EE1"/><w:sz w:val="24"/></w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="TOCHeading">
    <w:name w:val="TOC Heading"/>
    <w:basedOn w:val="Heading1"/>
    <w:qFormat/>
  </w:style>
  <w:style w:type="paragraph" w:styleId="CodeBlock">
    <w:name w:val="Code Block"/>
    <w:basedOn w:val="Normal"/>
    <w:pPr><w:spacing w:after="180"/><w:ind w:left="360"/></w:pPr>
    <w:rPr><w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/><w:sz w:val="20"/><w:color w:val="333333"/></w:rPr>
  </w:style>
  <w:style w:type="table" w:styleId="TableGrid">
    <w:name w:val="Table Grid"/>
    <w:basedOn w:val="TableNormal"/>
    <w:uiPriority w:val="39"/>
    <w:tblPr>
      <w:tblBorders>
        <w:top w:val="single" w:sz="4" w:space="0" w:color="D9DDEB"/>
        <w:left w:val="single" w:sz="4" w:space="0" w:color="D9DDEB"/>
        <w:bottom w:val="single" w:sz="4" w:space="0" w:color="D9DDEB"/>
        <w:right w:val="single" w:sz="4" w:space="0" w:color="D9DDEB"/>
        <w:insideH w:val="single" w:sz="4" w:space="0" w:color="D9DDEB"/>
        <w:insideV w:val="single" w:sz="4" w:space="0" w:color="D9DDEB"/>
      </w:tblBorders>
      <w:tblCellMar>
        <w:top w:w="120" w:type="dxa"/>
        <w:left w:w="120" w:type="dxa"/>
        <w:bottom w:w="120" w:type="dxa"/>
        <w:right w:w="120" w:type="dxa"/>
      </w:tblCellMar>
    </w:tblPr>
  </w:style>
</w:styles>"""


CONTENT_TYPES = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
</Types>"""

ROOT_RELS = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>"""

DOC_RELS = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>"""

CORE_XML = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
 xmlns:dc="http://purl.org/dc/elements/1.1/"
 xmlns:dcterms="http://purl.org/dc/terms/"
 xmlns:dcmitype="http://purl.org/dc/dcmitype/"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:title>Study Buddy Project Report</dc:title>
  <dc:subject>Flutter Android Student Productivity App</dc:subject>
  <dc:creator>Codex</dc:creator>
  <cp:keywords>Flutter, Dart, Study Buddy, Project Report</cp:keywords>
  <dc:description>University-level project report for the Study Buddy Flutter app.</dc:description>
</cp:coreProperties>"""

APP_XML = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"
 xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
  <Application>Microsoft Word</Application>
  <DocSecurity>0</DocSecurity>
  <ScaleCrop>false</ScaleCrop>
  <Company></Company>
  <LinksUpToDate>false</LinksUpToDate>
  <SharedDoc>false</SharedDoc>
  <HyperlinksChanged>false</HyperlinksChanged>
  <AppVersion>16.0000</AppVersion>
</Properties>"""


def main() -> None:
    with zipfile.ZipFile(OUT, "w", compression=zipfile.ZIP_DEFLATED) as docx:
        docx.writestr("[Content_Types].xml", CONTENT_TYPES)
        docx.writestr("_rels/.rels", ROOT_RELS)
        docx.writestr("word/_rels/document.xml.rels", DOC_RELS)
        docx.writestr("word/document.xml", build_document_xml())
        docx.writestr("word/styles.xml", build_styles_xml())
        docx.writestr("docProps/core.xml", CORE_XML)
        docx.writestr("docProps/app.xml", APP_XML)
    print(OUT.resolve())


if __name__ == "__main__":
    main()
