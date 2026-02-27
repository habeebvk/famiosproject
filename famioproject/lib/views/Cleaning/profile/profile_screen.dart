import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Replace with your actual login screen
import 'package:famioproject/views/auth/login_screen.dart';
import 'package:famioproject/services/auth_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      final userData = await AuthService().getCurrentUserData();
      if (userData != null) {
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
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
// import 'package:famioproject/views/auth/login_screen.dart'; // Make sure this path is correct

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//               const CircleAvatar(
//                 radius: 50,
//                 backgroundImage: NetworkImage(
//                   'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Alex Johnson',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'alex.johnson@email.com',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton.icon(
//                 onPressed: () {},
//                 icon: const Icon(Icons.edit),
//                 label: const Text('Edit Profile'),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 ),
//               ),
//               const SizedBox(height: 30),
              
//               // Contact Details
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Contact Details',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Icon(Icons.phone, color: Colors.grey[600], size: 20),
//                         const SizedBox(width: 12),
//                         const Text('+91 98765 43210'),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Icon(Icons.location_on, color: Colors.grey[600], size: 20),
//                         const SizedBox(width: 12),
//                         const Expanded(
//                           child: Text('123 Main Street\nMumbai, Maharashtra 400001\nIndia'),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
              
//               // Menu Options
//               ListTile(
//                 leading: const Icon(Icons.settings),
//                 title: const Text('Settings'),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: () {},
//               ),
//               const Divider(),
//               ListTile(
//                 leading: const Icon(Icons.info),
//                 title: const Text('About'),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: () {},
//               ),
//               const Divider(),
//               ListTile(
//                 leading: const Icon(Icons.logout, color: Colors.red),
//                 title: const Text(
//                   'Logout',
//                   style: TextStyle(color: Colors.red),
//                 ),
//                 onTap: () {
//                   showDialog(
//                     context: context,
//                     builder: (context) => AlertDialog(
//                       title: const Text('Logout'),
//                       content: const Text('Are you sure you want to logout?'),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(context),
//                           child: const Text('Cancel'),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             Navigator.of(context).pop(); // Close dialog
//                             // Navigate to LoginScreen and remove all previous routes
//                             Navigator.of(context).pushAndRemoveUntil(
//                               MaterialPageRoute(
//                                   builder: (context) => const LoginScreen()),
//                               (route) => false,
//                             );
//                           },
//                           child: const Text('Logout'),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
