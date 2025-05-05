
// ignore_for_file: use_super_parameters

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialimpact/pages/complete_profile_page.dart';
import 'package:socialimpact/pages/gerir_page.dart';
import 'package:socialimpact/routes.dart';
import 'package:socialimpact/services/instituicao_service.dart';

// ================== MAIN PAGE STRUCTURE ==================
class AppBasePage extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showSearch;
  final List<Widget>? appBarActions;
  final Color appBarColor;
  final Color footerColor;
  final double searchBarHeight;
  final double? searchBarWidth;

  const AppBasePage({
    super.key,
    required this.title,
    required this.body,
    this.showSearch = false,
    this.appBarActions,
    this.appBarColor = Colors.blueAccent,
    this.footerColor = Colors.blueAccent,
    this.searchBarHeight = 30,
    this.searchBarWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      endDrawer: const AppDrawerMenu(),
      body: Column(
        children: [
          Expanded(child: _buildBody(context)),
          AppFooter(color: footerColor),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    double calculatedWidth = searchBarWidth ?? MediaQuery.of(context).size.width * 0.6;
    return AppBar(
      title: showSearch
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: _appBarTextStyle),
                const SizedBox(width: 10),
                Expanded(
                  child: AppSearchBar(
                    height: searchBarHeight,
                    width: calculatedWidth,
                  ),
                ),
              ],
            )
          : Text(title, style: _appBarTextStyle),
      backgroundColor: appBarColor,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: appBarActions,
      automaticallyImplyLeading: true,
    );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: body,
      ),
    );
  }

  static const TextStyle _appBarTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );
}

// ================== NAVIGATION DRAWER ==================
class AppDrawerMenu extends StatelessWidget {
  const AppDrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 16,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            ..._buildMenuSections(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GerirPage()),
            ),
            icon: const Icon(Icons.account_circle),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CompleteProfilePage()),
            ),
            icon: const Icon(Icons.manage_accounts_rounded),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<bool> _isInstituicao() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final instituicaoService = InstituicaoService();
    final instituicao = await instituicaoService.getInstituicaoByEmail(user.email!);
    return instituicao != null;
  }

  List<Widget> _buildMenuSections(BuildContext context) {
    return [
      // Home Section
      _buildMenuSection(
        context,
        sectionTitle: 'Home',
        items: [
          _buildMenuItem(context, 'Home', Icons.home, AppRoutes.home),
        ],
      ),
      // Login
      _buildMenuSection(
        context,
        sectionTitle: 'Login',
        items: [
          _buildMenuItem(context, 'Login', Icons.login, AppRoutes.loginSignup),
        ],
      ),
      // Gerir Page
      _buildMenuSection(
        context,
        sectionTitle: 'Gerir Recursos',
        items: [
          _buildMenuItem(context, 'Gerir', Icons.manage_accounts, AppRoutes.gerirPage),
        ],
      ),
      FutureBuilder<bool>(
        future: _isInstituicao(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink(); // Avoid showing anything while loading
          }
          if (snapshot.hasData && snapshot.data == true) {
            return Column(
              children: [
                // Projeto Causa Section
                _buildMenuSection(
                  context,
                  sectionTitle: 'Projeto Causa',
                  items: [
                    _buildMenuItem(context, 'Criar Projetos Causa', Icons.add_business, AppRoutes.addProjetoCausa),
                  ],
                ),
                // Ação de Voluntariado Section
                _buildMenuSection(
                  context,
                  sectionTitle: 'Ações de Voluntariado',
                  items: [
                    _buildMenuItem(context, 'Criar Ações de Voluntariado', Icons.add_task, AppRoutes.addAcaoVoluntariado),
                  ],
                ),
              ],
            );
          }
          return const SizedBox.shrink(); // Don't show these sections for non-Instituição users
        },
      ),
    ];
  }

  Widget _buildMenuSection(BuildContext context, {required String sectionTitle, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            sectionTitle.toUpperCase(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pop(context); // Close drawer before navigation
        Navigator.pushNamed(context, route);
      },
    );
  }
}

// ================== FOOTER COMPONENT ==================
class AppFooter extends StatelessWidget {
  final Color color;

  const AppFooter({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        boxShadow: _footerShadow,
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FooterText(),
          SizedBox(height: 8),
          _SocialMediaRow(),
        ],
      ),
    );
  }

  static final List<BoxShadow> _footerShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      spreadRadius: 2,
      blurRadius: 8,
      offset: Offset(0, 3),
    ),
  ];
}

class _FooterText extends StatelessWidget {
  const _FooterText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'SocialImpact@2025',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _SocialMediaRow extends StatelessWidget {
  const _SocialMediaRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.facebook, color: Colors.white, size: 24),
        SizedBox(width: 14),
        Icon(Icons.mail, color: Colors.white, size: 24),
      ],
    );
  }
}

// ================== SEARCH COMPONENT ==================
class AppSearchBar extends StatelessWidget {
  final ValueChanged<String>? onSearch;
  final String hintText;
  final double? width;
  final double height;

  const AppSearchBar({
    super.key,
    this.onSearch,
    this.hintText = 'Search...',
    this.width,
    this.height = 35,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: (height - 24) / 2,
            horizontal: 16,
          ),
        ),
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        onChanged: onSearch,
      ),
    );
  }
}

