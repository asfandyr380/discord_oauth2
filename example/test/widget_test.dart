import 'package:flutter_test/flutter_test.dart';
import 'package:discord_oauth2/discord_oauth2.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('Discord Sign In Button renders successfully on MobileScreen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title is displayed.
    expect(find.text('Discord OAuth2 Mobile Client'), findsOneWidget);

    // Verify that the helper description is displayed.
    expect(
      find.text(
        'This mobile interface requests authorization and retrieves a temporary code to pass to your backend securely.',
      ),
      findsOneWidget,
    );

    // Verify that the pre-styled Discord Sign In button is present.
    expect(find.byType(DiscordSignInButton), findsOneWidget);
    expect(find.text('Sign in with Discord'), findsOneWidget);
  });
}
