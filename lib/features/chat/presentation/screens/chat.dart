import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:incacook/core/common/widgets/custon_shapes/container/circular_image.dart';
import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/utils/device/device_utility.dart';
import 'package:incacook/core/widgets/decor/decor_blob.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/chat/presentation/widgets/chat_input_field.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //* CustomAppBar's own preferredSize is just kToolbarHeight (56dp) and
    //* doesn't add the status bar inset, so the title overflows on notched
    //* devices. Match the settings/client_home pattern: wrap in
    //* PreferredSize with statusBar + 56 so the inner content has the full
    //* 56dp to render the user-header pill.
    final appBarHeight =
        MediaQuery.viewPaddingOf(context).top + AppSizes.appBarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: CustomAppBar(
          showBackArrow: true,
          //* frosted "user header" pill — name + presence status, sits
          //* next to the (also frosted) back button so the appbar reads
          //* as one coherent glass strip.
          title: FrostedSurface(
            borderRadius: BorderRadius.circular(999),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.xs + 2,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'John Doe',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomCircularContainer(
                      size: 8,
                      backgroundColor: Colors.green,
                    ),
                    const Gap(AppSizes.xs),
                    Text(
                      'Online',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [CustomCircularImage(image: AppImages.profilePic, size: 40)],
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            //* decorative top-right blob — gives the frosted input field
            //* something to blur over so the glass effect actually reads.
            const Positioned(
              top: -8,
              right: -16,
              child: IgnorePointer(child: DecorBlob()),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: DeviceUtils.getBottomNavigationBarHeight() / 2.4,
              child: ChatInputField(
                onSend: (message) {},
                onAttach: () {},
                onMic: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
