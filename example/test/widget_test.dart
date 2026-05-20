import 'package:flutter_test/flutter_test.dart';
import 'package:discord_oauth2/discord_oauth2.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('Discord Sign In Button renders successfully', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title is displayed.
    expect(find.text('Discord Package Demo'), findsOneWidget);

    // Verify that the helper description is displayed.
    expect(
      find.text(
        'This client app only retrieves the temporary authorization code. No secrets or tokens are stored on-device.',
      ),
      findsOneWidget,
    );

    // Verify that the pre-styled Discord Sign In button is present.
    expect(find.byType(DiscordSignInButton), findsOneWidget);
    expect(find.text('Sign in with Discord'), findsOneWidget);
  });
}
