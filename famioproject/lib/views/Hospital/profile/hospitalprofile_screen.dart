import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Replace with your actual login screen
import 'package:famioproject/views/auth/login_screen.dart';
import 'package:famioproject/services/auth_services.dart';

class HospitalAdminProfilePage extends StatefulWidget {
  const HospitalAdminProfilePage({super.key});

  @override
  State<HospitalAdminProfilePage> createState() =>
      _HospitalAdminProfilePageState();
}

class _HospitalAdminProfilePageState extends State<HospitalAdminProfilePage> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Uber Blue
  static const Color _uberBlue = Color(0xFF0068FF);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await AuthService()
          .getCurrentUserData(); // Assuming you can instantiate AuthService directly or use a singleton/provider
      if (userData != null) {
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          // Phone might not be in the basic register flow, checking if it exists
          if (userData.containsKey('phone')) {
            _phoneController.text = userData['phone'];
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(LucideIcons.camera, color: _uberBlue),
              title: const Text("Take Photo"),
              onTap: () => _pickFromSource(ImageSource.camera),
            ),
            ListTile(
              leading: Icon(LucideIcons.image, color: _uberBlue),
              title: const Text("Choose from Gallery"),
              onTap: () => _pickFromSource(ImageSource.gallery),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(LucideIcons.x, color: Colors.grey),
              title: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromSource(ImageSource source) async {
    Navigator.pop(context);
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Profile updated successfully!"),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? Icon(
                            LucideIcons.user,
                            size: 70,
                            color: Colors.grey[600],
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: _uberBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.camera,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Tap to change photo",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Name Field
            _buildTextField(
              controller: _nameController,
              label: "Name",
              icon: LucideIcons.user,
            ),
            const SizedBox(height: 16),

            // Email Field
            _buildTextField(
              controller: _emailController,
              label: "Email",
              icon: LucideIcons.mail,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Phone Field
            _buildTextField(
              controller: _phoneController,
              label: "Phone",
              icon: LucideIcons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),

            // Save Button
            // SizedBox(
            //   width: double.infinity,
            //   height: 52,
            //   child: ElevatedButton.icon(
            //     onPressed: _saveProfile,
            //     icon: const Icon(LucideIcons.save, size: 20),
            //     label: const Text("Save Changes", style: TextStyle(fontSize: 16)),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: _uberBlue,
            //       foregroundColor: Colors.white,
            //       elevation: 2,
            //       shadowColor: _uberBlue.withOpacity(0.3),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 12),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(
                  LucideIcons.logOut,
                  size: 20,
                  color: Colors.red,
                ),
                label: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Reusable TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black87, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
        prefixIcon: Icon(icon, color: _uberBlue),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _uberBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:famioproject/views/auth/login_screen.dart';

// class HospitaladminProfilePage extends StatefulWidget {
//   const HospitaladminProfilePage({super.key});

//   @override
//   State<HospitaladminProfilePage> createState() => _AdminProfilePageState();
// }

// class _AdminProfilePageState extends State<HospitaladminProfilePage> {
//   bool _notificationsEnabled = true;
//   bool _isDarkTheme = false;

//   void _changePassword() {
//     final _currentController = TextEditingController();
//     final _newController = TextEditingController();
//     final _confirmController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Change Password'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: _currentController,
//                 obscureText: true,
//                 decoration: const InputDecoration(labelText: 'Current Password'),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 controller: _newController,
//                 obscureText: true,
//                 decoration: const InputDecoration(labelText: 'New Password'),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 controller: _confirmController,
//                 obscureText: true,
//                 decoration: const InputDecoration(labelText: 'Confirm Password'),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (_newController.text != _confirmController.text) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Passwords do not match')),
//                 );
//               } else if (_currentController.text.isEmpty || _newController.text.isEmpty) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Please fill all fields')),
//                 );
//               } else {
//                 Navigator.pop(ctx);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Password changed successfully')),
//                 );
//               }
//             },
//             child: const Text('Change'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _logout() {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Logout'),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(ctx);
//               Navigator.of(context).pushAndRemoveUntil(
//                 MaterialPageRoute(builder: (context) => const LoginScreen()),
//                 (route) => false,
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//             ),
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       appBar: AppBar(
//         title: const Text(' Profile',style: TextStyle(color: Colors.white),),
//         centerTitle: true,
//         backgroundColor: Colors.teal,
//         elevation: 0,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // Admin Info Header
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Colors.teal, Colors.tealAccent],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.teal.withOpacity(0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 const CircleAvatar(
//                   radius: 40,
//                   backgroundImage: NetworkImage('https://via.placeholder.com/150'),
//                 ),
//                 const SizedBox(width: 16),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: const [
//                     Text(
//                       'Admin Name',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       'admin@example.com',
//                       style: TextStyle(color: Colors.white70, fontSize: 16),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 24),

//           // Change Password
//           Card(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             elevation: 3,
//             child: ListTile(
//               leading: const Icon(Icons.lock, color: Colors.orange),
//               title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
//               trailing: const Icon(Icons.arrow_forward_ios, size: 18),
//               onTap: _changePassword,
//             ),
//           ),

//           const SizedBox(height: 16),

//           // App Preferences
//           Card(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             elevation: 3,
//             child: Column(
//               children: [
//                 SwitchListTile(
//                   title: const Text('Enable Notifications'),
//                   value: _notificationsEnabled,
//                   onChanged: (val) {
//                     setState(() {
//                       _notificationsEnabled = val;
//                     });
//                   },
//                   secondary: const Icon(Icons.notifications, color: Colors.teal),
//                   activeColor: Colors.teal,
//                 ),
//                 const Divider(height: 1),
//                 SwitchListTile(
//                   title: const Text('Dark Theme'),
//                   value: _isDarkTheme,
//                   onChanged: (val) {
//                     setState(() {
//                       _isDarkTheme = val;
//                       // TODO: Implement theme change logic
//                     });
//                   },
//                   secondary: const Icon(Icons.dark_mode, color: Colors.grey),
//                   activeColor: Colors.teal,
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Logout
//           Card(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             elevation: 3,
//             child: ListTile(
//               leading: const Icon(Icons.logout, color: Colors.red),
//               title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
//               onTap: _logout,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
