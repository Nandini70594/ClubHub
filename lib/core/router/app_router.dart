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
import '../../features/club/budget_submission_screen.dart';
import '../../features/club/club_dashboard_screen.dart';
import '../../features/club/create_event_screen.dart';
import '../../features/club/event_detail_screen.dart';
import '../../features/club/permission_request_details_screen.dart';
import '../../features/club/permission_request_screen.dart';
import '../../features/proposal_approver/proposal_approver_dashboard_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../models/permission_request_model.dart';
import '../../features/proposal_approver/proposal_approver_home_screen.dart';
import '../../features/club/event_expense_submission_screen.dart';
import '../../features/budget_approver/budget_approver_home_screen.dart';
import '../../features/budget_approver/expense_approver_dashboard_screen.dart';
import '../../features/club/event_closing_submission_screen.dart';
import '../../features/common/event_archive_screen.dart';
import '../../features/vertical_coordinator/vertical_coordinator_home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/club',
        builder: (context, state) => const ClubDashboardScreen(),
      ),
      GoRoute(
        path: '/club/create-event',
        builder: (context, state) => const CreateEventScreen(),
      ),
      GoRoute(
        path: '/club/event/:id',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return EventDetailScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/club/event/:id/budget',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return BudgetSubmissionScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/club/event/:eventId/permissions',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          final extra = state.extra;

          return PermissionRequestScreen(
            eventId: eventId,
            resubmittingRequest:
                extra is PermissionRequestModel ? extra : null,
          );
        },
      ),
      GoRoute(
        path: '/club/permission-request/:requestId',
        builder: (context, state) {
          final requestId = state.pathParameters['requestId']!;
          return PermissionRequestDetailsScreen(requestId: requestId);
        },
      ),
      GoRoute(
  path: '/proposal-approver',
  builder: (context, state) => const ProposalApproverHomeScreen(),
),
GoRoute(
  path: '/proposal-approver/proposals',
  builder: (context, state) => const ProposalApproverDashboardScreen(),
),
      GoRoute(
        path: '/proposal-approver/review/:id',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return ProposalReviewScreen(eventId: eventId);
        },
      ),
      GoRoute(
  path: '/budget-approver',
  builder: (context, state) => const BudgetApproverHomeScreen(),
),
GoRoute(
  path: '/budget-approver/budgets',
  builder: (context, state) => const BudgetApproverDashboardScreen(),
),
GoRoute(
  path: '/budget-approver/expenses',
  builder: (context, state) => const ExpenseApproverDashboardScreen(),
),
      GoRoute(
        path: '/budget-approver/review',
        builder: (context, state) {
          final budget = state.extra as dynamic;
          return BudgetReviewScreen(budget: budget);
        },
      ),
      GoRoute(
        path: '/permission-approver',
        builder: (context, state) => const PermissionApproverDashboardScreen(),
      ),

      GoRoute(
        path: '/permission-approver/review',
        builder: (context, state) {
          final request = state.extra as PermissionRequestModel;
          return PermissionReviewScreen(request: request);
        },
      ),

      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      GoRoute(
  path: '/club/event/:id/expenses',
  builder: (context, state) {
    final eventId = state.pathParameters['id']!;
    return EventExpenseSubmissionScreen(eventId: eventId);
  },
),
GoRoute(
  path: '/club/event/:id/closing',
  builder: (context, state) {
    final eventId = state.pathParameters['id']!;
    return EventClosingSubmissionScreen(eventId: eventId);
  },
),
GoRoute(
  path: '/vertical-coordinator',
  builder: (context, state) => const VerticalCoordinatorHomeScreen(),
),
GoRoute(
  path: '/archive',
  builder: (context, state) => const EventArchiveScreen(),
),
    ],
    redirect: (context, state) {
      final user = Supabase.instance.client.auth.currentUser;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/';

      if (user == null) {
        if (isLoggingIn || isSplash) return null;
        return '/login';
      }

      if (user != null && (isLoggingIn || isSplash)) {
        return null;
      }

      return null;
    },
  );
});