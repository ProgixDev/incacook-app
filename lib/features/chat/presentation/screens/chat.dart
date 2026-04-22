import 'package:flutter/material.dart';
import 'package:vinted_v2/core/common/widgets/appbar/appbar.dart';
import 'package:vinted_v2/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:vinted_v2/core/common/widgets/custon_shapes/container/circular_image.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/image_strings.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/utils/device/device_utility.dart';
import 'package:vinted_v2/core/utils/device_utils.dart';
import 'package:vinted_v2/features/chat/presentation/widgets/chat_input_field.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: AppColors.lightBackground,
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('John Doe', style: Theme.of(context).textTheme.titleMedium),
            Row(
              children: [
                CustomCircularContainer(size: 8, backgroundColor: Colors.green),
                Text('Online', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ],
        ),
        actions: [
          CustomCircularImage(
            image: AppImages.profilePic,
            size: 70,
          ),
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
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
