import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import '../login.dart';


class RoleGuard extends StatefulWidget {
  final Widget child;
  final String requiredRole; 
  final Widget? fallbackPage; // Halaman jika role tidak sesuai

  const RoleGuard({
    super.key,
    required this.child,
    required this.requiredRole,
    this.fallbackPage,
  });

  @override
  State<RoleGuard> createState() => _RoleGuardState();
}

class _RoleGuardState extends State<RoleGuard> {
  bool isChecking = true;
  bool hasAccess = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final authService = AuthServices();
    
    // Cek apakah sudah login
    final isLoggedIn = await authService.isLoggedIn();
    
    if (!isLoggedIn) {
      // Jika belum login, redirect ke login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
      return;
    }

    // Cek role
    final userRole = await authService.getUserRole();
    
    setState(() {
      hasAccess = userRole == widget.requiredRole;
      isChecking = false;
    });

    // Jika role tidak sesuai, redirect ke fallback
    if (!hasAccess && widget.fallbackPage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => widget.fallbackPage!),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!hasAccess) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Akses Ditolak',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda tidak memiliki akses ke halaman ini',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('Kembali ke Login'),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}

/// Widget untuk cek apakah sudah login (tanpa cek role)
class AuthGuard extends StatefulWidget {
  final Widget child;

  const AuthGuard({
    super.key,
    required this.child,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool isChecking = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await AuthServices().isLoggedIn();
    
    setState(() {
      isLoggedIn = loggedIn;
      isChecking = false;
    });

    if (!loggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return isLoggedIn ? widget.child : const SizedBox.shrink();
  }
}