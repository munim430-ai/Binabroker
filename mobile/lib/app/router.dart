import 'package:binabroker/features/auth/login_screen.dart';
import 'package:binabroker/features/auth/otp_screen.dart';
import 'package:binabroker/features/listings/add_listing_screen.dart';
import 'package:binabroker/features/listings/listing_details_screen.dart';
import 'package:binabroker/features/listings/listing_model.dart';
import 'package:binabroker/features/listings/listings_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const ListingsScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(
      path: '/otp/:phone',
      builder: (_, state) => OtpScreen(phone: state.pathParameters['phone']!),
    ),
    GoRoute(path: '/add', builder: (_, __) => const AddListingScreen()),
    GoRoute(
      path: '/details',
      builder: (_, state) => ListingDetailsScreen(listing: state.extra as Listing),
    ),
  ],
);
