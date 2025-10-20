class RouterConstant {
  static final String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String studyMaterial = '/study_material';
  static const String solvedAssignments = '/solved_assignments';
  static const String contact = '/contact';
  static const String profile = '/profile';
  static const String adminHome = '/admin_home';
  static const String allUsers = '/all_users';
  static const String courses = '/courses';
  static const String subject = '/subjects';

  static String adminUsers = adminHome + allUsers;
  static String adminCourses = adminHome + courses;
  static String adminSubjects = adminHome +subject;
}