class Group {
  String name = "";
  String id = "";

  static final Group _currentGroup = Group("", "");
  static String get groupName => _currentGroup.name;
  static String get groupID => _currentGroup.id;
  static set groupName(name) => _currentGroup.name = name;
  static set groupID(id) => _currentGroup.id = id;

  Group(String name, String id);
}
