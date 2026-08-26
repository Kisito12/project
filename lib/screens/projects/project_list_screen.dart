import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/company.dart';
import '../../models/project.dart';
import '../../services/app_state.dart';
import '../../services/project_service.dart';
import '../../theme/app_theme.dart';
import 'create_project_screen.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends StatelessWidget {
  final Company company;
  final AppUser user;

  const ProjectListScreen({super.key, required this.company, required this.user});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final projectService = ProjectService();
    final stream = user.isCompanyAdmin
        ? projectService.watchProjectsForCompany(company.id)
        : projectService.watchProjectsForWorker(user.uid);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: StreamBuilder<List<Project>>(
          stream: stream,
          builder: (context, snapshot) {
            final projects = snapshot.data ?? [];
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    user: user,
                    company: company,
                    onSignOut: () => appState.authService.signOut(),
                  ),
                ),
                SliverToBoxAdapter(child: _StatsRow(projects: projects)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Projects',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        if (user.isCompanyAdmin)
                          _NewProjectButton(company: company),
                      ],
                    ),
                  ),
                ),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (projects.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          user.isCompanyAdmin
                              ? 'No projects yet. Tap "+ New" to create one.'
                              : 'No projects assigned to you yet.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList.separated(
                      itemCount: projects.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        return _ProjectCard(
                          project: project,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProjectDetailScreen(project: project, user: user),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppUser user;
  final Company company;
  final VoidCallback onSignOut;

  const _Header({required this.user, required this.company, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    final firstName = user.name.trim().isEmpty ? 'there' : user.name.trim().split(' ').first;
    final initials = user.name.trim().isEmpty
        ? '?'
        : user.name.trim().split(' ').map((p) => p[0]).take(2).join().toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hi $firstName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text(
                  '${company.name} · ${user.isCompanyAdmin ? "Company Admin" : "Worker"}',
                  style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.textSecondary),
            tooltip: 'Sign out',
            onPressed: onSignOut,
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<Project> projects;

  const _StatsRow({required this.projects});

  @override
  Widget build(BuildContext context) {
    final active = projects.where((p) => p.status == ProjectStatus.active).length;
    final planning = projects.where((p) => p.status == ProjectStatus.planning).length;
    final completed = projects.where((p) => p.status == ProjectStatus.completed).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(child: _StatCard(value: '$active', label: 'Active', color: AppTheme.primary)),
          const SizedBox(width: 10),
          Expanded(child: _StatCard(value: '$planning', label: 'Planning', color: const Color(0xFFE0A32E))),
          const SizedBox(width: 10),
          Expanded(child: _StatCard(value: '$completed', label: 'Completed', color: const Color(0xFF5B8DEF))),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _NewProjectButton extends StatelessWidget {
  final Company company;

  const _NewProjectButton({required this.company});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CreateProjectScreen(company: company)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(999)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text('New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const _ProjectCard({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Thumbnail(project: project),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.name,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _StatusPill(status: project.status),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    project.clientName.isEmpty ? project.location : '${project.clientName} · ${project.location}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: _statusProgress(project.status),
                      minHeight: 6,
                      backgroundColor: const Color(0xFFEFF3EF),
                      valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _statusProgress(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return 0.08;
      case ProjectStatus.active:
        return 0.55;
      case ProjectStatus.onHold:
        return 0.4;
      case ProjectStatus.completed:
        return 1;
    }
  }
}

class _Thumbnail extends StatelessWidget {
  final Project project;

  const _Thumbnail({required this.project});

  @override
  Widget build(BuildContext context) {
    if (project.planFileUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: CachedNetworkImage(
          imageUrl: project.planFileUrl!,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3EF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.home_work_outlined, color: AppTheme.primary),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final ProjectStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ProjectStatus.planning => ('Planning', const Color(0xFFE0A32E)),
      ProjectStatus.active => ('Active', AppTheme.primary),
      ProjectStatus.onHold => ('On hold', const Color(0xFF9AA5A0)),
      ProjectStatus.completed => ('Done', const Color(0xFF5B8DEF)),
    };
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w800)),
    );
  }
}
