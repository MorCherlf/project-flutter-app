import 'package:flutter/material.dart';
import 'package:project/widgets/float_navigation_bar.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // 在这里处理导航逻辑
    if (index == 0) {
      print('Detail tapped');
    } else if (index == 1) {
      print('Applications tapped');
    }
  }

  Widget _buildDetailTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.crop_square, size: 48, color: Colors.grey),
                Icon(Icons.circle_outlined, size: 48, color: Colors.grey),
                Icon(Icons.play_arrow, size: 48, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Title',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Subtitle',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce sed dapibus mi, eget sodales massa. Fusce iaculis laoreet ligula, et vehicula velit vulputate vel. Donec eu odio ornare, interdum est sed, mollis metus. Nulla sodales blandit leo. Morbi vitae neque ac nunc gravida scelerisque. Nullam id bibendum neque. Donec fermentum enim ut ex tempus, nec dapibus ipsum blandit. Cras non varius ligula. Nunc eget arcu est.',
            style: TextStyle(fontSize: 14),
          ),
          const Text(
            'Fusce nisl risus, mattis at ex sit amet, commodo facilisis mi. Curabitur nec tortor eget nulla volutpat placerat. Duis et arcu a elit porttitor venenatis sagittis sit amet lacus. Proin eu magna a ipsum convallis rhoncus et nec justo. Proin vel nulla nec metus dictum porta porta id mi. Phasellus eget mauris tortor. Quisque lorem erat, sollicitudin eu ornare vitae, ornare nec elit. Suspendisse aliquam scelerisque malesuada.',
            style: TextStyle(fontSize: 14),
          ),
          const Text(
            'Sed sed urna eros. Aenean imperdiet rhoncus tristique. Proin in arcu et tortor dapibus faucibus. Nulla facilisi. Curabitur ut nulla cursus, interdum lectus a, sollicitudin diam. Ut tincidunt ac enim in tristique. Nullam at suscipit arcu. Nullam et auctor velit. Maecenas cursus neque sit amet sem vehicula lobortis. Mauris sit amet urna consequat, ultrices lorem non, dignissim neque. Praesent imperdiet, nibh non blandit sagittis, odio massa tempus lectus, ut laoreet nibh nibh placerat quam. Morbi maximus sit amet magna sit amet bibendum. Curabitur dui ligula, rhoncus at tincidunt at, ultrices a erat. Pellentesque molestie, sem in convallis blandit, magna orci sollicitudin tellus, nec bibendum urna quam eu enim. Sed a ultricies lectus. Aliquam erat volutpat.',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildApplicationsTab() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated( // Expanded 被移除
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 20,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  child: const Text('A'),
                ),
                title: const Text('Complete'),
                subtitle: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Applicant'),
                    Text(
                      'Supporting line text lorem ipsum dolor sit ameta, consectetur.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                onTap: () {
                  print('Tapped on item ${index + 1}');
                },
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 1),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 150.0,
                floating: false,
                pinned: true,
                leading: const BackButton(),
                actions: const [
                  Icon(Icons.redo),
                  SizedBox(width: 20),
                  Icon(Icons.calendar_today_outlined),
                  SizedBox(width: 20),
                  Icon(Icons.more_vert),
                  SizedBox(width: 16),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Device',
                    style: TextStyle(fontSize: 18),
                  ),
                  centerTitle: false,
                  background: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  _selectedIndex == 0 ? _buildDetailTab() : _buildApplicationsTab(),
                ]),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 80.0, right: 80.0, bottom: 36.0),
              child: FloatNavigationBar(
                items: const [
                  FloatNavigationBarItem(
                    icon: Icons.info,
                    activeIcon: Icons.info_outline,
                    label: 'Detail',
                  ),
                  FloatNavigationBarItem(
                    icon: Icons.apps,
                    activeIcon: Icons.apps_outlined,
                    label: 'Applications',
                  ),
                ],
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
            ),
          ),
        ],
      ),
    );
  }
}