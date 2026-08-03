import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/services/index.dart';
import 'package:praxis/common/style/design_tokens.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ErrorService.showWarning('请输入邮箱地址');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AuthService.signInWithMagicLink(email);
      if (!mounted) return;
      ErrorService.showSuccess('登录链接已发送，请检查邮箱。');
      Get.back(result: true);
    } catch (error) {
      ErrorService.handleError(error, context: 'Magic link 登录');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('登录 Praxis')),
      backgroundColor:
          isDark ? DesignTokens.backgroundDark : DesignTokens.backgroundLight,
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spacing6),
        children: [
          Text(
            '输入邮箱后，Praxis 会发送一个 magic link 给你，用于登录云端账号。',
            style: DesignTokens.textStyle(
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing5),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: '邮箱地址',
              hintText: 'you@example.com',
            ),
          ),
          const SizedBox(height: DesignTokens.spacing5),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: Text(_isSubmitting ? '发送中...' : '发送登录链接'),
            ),
          ),
        ],
      ),
    );
  }
}
