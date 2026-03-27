import os

# 1. Update home_page.dart
f_path = r'c:\Projects\Flutter\internship\Dreamventz\dreamventz\lib\screens\home\home_page.dart'
with open(f_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace(
    '  String userName = \'User\';\n  bool isLoadingUser = true;',
    '  String userName = \'User\';\n  String? avatarUrl;\n  bool isLoadingUser = true;'
)

content = content.replace(
    '.select(\'full_name\')\n            .eq(\'id\', userId)',
    '.select(\'full_name, avatar_url\')\n            .eq(\'id\', userId)'
)

content = content.replace(
    '        setState(() {\n          userName = response[\'full_name\'] ?? \'User\';\n          isLoadingUser = false;\n        });',
    '        setState(() {\n          userName = response[\'full_name\'] ?? \'User\';\n          avatarUrl = response[\'avatar_url\'];\n          isLoadingUser = false;\n        });'
)

content = content.replace(
    '              HomeHeader(\n                isLoadingUser: isLoadingUser,\n                userName: userName,\n              ),',
    '              HomeHeader(\n                isLoadingUser: isLoadingUser,\n                userName: userName,\n                avatarUrl: avatarUrl,\n              ),'
)

with open(f_path, 'w', encoding='utf-8', newline='') as f:
    f.write(content)

# 2. Update home_header.dart
f_path2 = r'c:\Projects\Flutter\internship\Dreamventz\dreamventz\lib\screens\home\widgets\home_header.dart'
with open(f_path2, 'r', encoding='utf-8') as f:
    content2 = f.read()

content2 = content2.replace(
    '  final bool isLoadingUser;\n  final String userName;\n\n  const HomeHeader({\n    super.key,\n    required this.isLoadingUser,\n    required this.userName,\n  });',
    '  final bool isLoadingUser;\n  final String userName;\n  final String? avatarUrl;\n\n  const HomeHeader({\n    super.key,\n    required this.isLoadingUser,\n    required this.userName,\n    this.avatarUrl,\n  });'
)

icon_block = '''                  child: Icon(
                    Icons.person,
                    color: Color.fromARGB(255, 212, 175, 55),
                    size: 24,
                  ),'''
                  
avatar_block = '''                  child: ClipOval(
                    child: avatarUrl != null && avatarUrl!.isNotEmpty
                        ? Image.network(
                            avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.person,
                                  color: Color.fromARGB(255, 212, 175, 55),
                                  size: 24,
                                ),
                          )
                        : const Icon(
                            Icons.person,
                            color: Color.fromARGB(255, 212, 175, 55),
                            size: 24,
                          ),
                  ),'''

content2 = content2.replace(icon_block, avatar_block)

with open(f_path2, 'w', encoding='utf-8', newline='') as f:
    f.write(content2)

print('Successfully patched files')
