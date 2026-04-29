import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/approver/budget_review_screen.dart';
import '../../features/approver/permission_approver_dashboard_screen.dart';
import '../../features/approver/permission_review_screen.dart';
import '../../features/approver/proposal_review_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/budget_approver/budget_approver_dashboard_screen.dart';
import '../../features/budget_approver/budget_approver_home_screen.dart';
import '../../features/budget_approver/expense_approver_dashboard_screen.dart';
import '../../features/club/budget_submission_screen.dart';
import '../../features/club/club_dashboard_screen.dart';
import '../../features/club/create_event_screen.dart';
import '../../features/club/event_closing_submission_screen.dart';
import '../../features/club/event_detail_screen.dart';
import '../../features/club/event_expense_submission_screen.dart';
import '../../features/club/permission_request_details_screen.dart';
import '../../features/club/permission_request_screen.dart';
import '../../features/common/event_archive_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/proposal_approver/proposal_approver_dashboard_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/vertical_coordinator/vertical_coordinator_home_screen.dart';
import '../../models/permission_request_model.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const profile = '/profile';
  static const archive = '/archive';
  static const club = '/club';
  static const createEvent = '/club/create-event';
  static const eventDetail = '/club/event';
  static const eventBudget = '/club/event/budget';
  static const eventExpenses = '/club/event/expenses';
  static const eventClosing = '/club/event/closing';
  static const permRequest = '/club/permission-request';
  static const permDetails = '/club/permission-details';
  static const proposalApprover = '/proposal-approver';
  static const proposalApproverList = '/proposal-approver/proposals';
  static const proposalReview = '/proposal-approver/review';
  static const budgetApprover = '/budget-approver';
  static const budgetApproverList = '/budget-approver/budgets';
  static const expenseApprover = '/budget-approver/expenses';
  static const budgetReview = '/budget-approver/review';
  static const permApprover = '/permission-approver';
  static const permReview = '/permission-approver/review';
  static const admin = '/admin';
  static const verticalCoordinator = '/vertical-coordinator';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/club', builder: (context, state) => const ClubDashboardScreen()),
      GoRoute(path: '/club/create-event', builder: (context, state) => const CreateEventScreen()),
      GoRoute(
        path: '/club/event/:id',
        builder: (context, state) => EventDetailScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/club/event/:id/budget',
        builder: (context, state) => BudgetSubmissionScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/club/event/:id/expenses',
        builder: (context, state) => EventExpenseSubmissionScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/club/event/:id/closing',
        builder: (context, state) => EventClosingSubmissionScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/club/event/:eventId/permissions',
        builder: (context, state) {
          final extra = state.extra;
          return PermissionRequestScreen(
            eventId: state.pathParameters['eventId']!,
            resubmittingRequest: extra is PermissionRequestModel ? extra : null,
          );
        },
      ),
      GoRoute(
        path: '/club/permission-request/:requestId',
        builder: (context, state) => PermissionRequestDetailsScreen(requestId: state.pathParameters['requestId']!),
      ),
      GoRoute(
  path: '/proposal-approver',
  builder: (context, state) => const ProposalApproverDashboardScreen(),
),
      GoRoute(path: '/proposal-approver/proposals', builder: (context, state) => const ProposalApproverDashboardScreen()),
      GoRoute(
        path: '/proposal-approver/review/:id',
        builder: (context, state) => ProposalReviewScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/budget-approver', builder: (context, state) => const BudgetApproverHomeScreen()),
      GoRoute(path: '/budget-approver/budgets', builder: (context, state) => const BudgetApproverDashboardScreen()),
      GoRoute(path: '/budget-approver/expenses', builder: (context, state) => const ExpenseApproverDashboardScreen()),
      GoRoute(
        path: '/budget-approver/review',
        builder: (context, state) => BudgetReviewScreen(budget: state.extra as dynamic),
      ),
      GoRoute(path: '/permission-approver', builder: (context, state) => const PermissionApproverDashboardScreen()),
      GoRoute(
        path: '/permission-approver/review',
        builder: (context, state) => PermissionReviewScreen(request: state.extra as PermissionRequestModel),
      ),
      GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(path: '/vertical-coordinator', builder: (context, state) => const VerticalCoordinatorHomeScreen()),
      GoRoute(path: '/archive', builder: (context, state) => const EventArchiveScreen()),
    ],
    redirect: (context, state) {
      final user = Supabase.instance.client.auth.currentUser;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/';

      if (user == null) {
        if (isLoggingIn || isSplash) return null;
        return '/login';
      }

      if (user != null && (isLoggingIn || isSplash)) return null;
      return null;
    },
  );
});

String initialRouteForRole(String? role) {
  switch (role) {
    case 'club_lead':
      return '/club';
    case 'proposal_approver':
      return '/proposal-approver';
    case 'budget_approver':
      return '/budget-approver';
    case 'resource_incharge':
    case 'director':
      return '/permission-approver';
    case 'vertical_coordinator':
      return '/vertical-coordinator';
    case 'admin':
      return '/admin';
    default:
      return '/login';
  }
}
