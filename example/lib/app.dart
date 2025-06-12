import 'package:aero_ui/aero_ui.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  Widget _buildSamplePanel(String text, Color color) {
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resizable Panels Demo')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Horizontal Resizing:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: ResizablePanelLayout(
              direction: Axis.horizontal,
              children: [
                _buildSamplePanel('Panel 1', Colors.blueGrey),
                _buildSamplePanel('Panel 2', Colors.teal),
                _buildSamplePanel('Panel 3', Colors.indigo),
              ],
            ),
          ),
          const Divider(height: 20, thickness: 2),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Vertical Resizing (2 panels):",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: ResizablePanelLayout(
              direction: Axis.vertical,
              dividerThickness: 10,
              dividerColor: Colors.orange.withValues(alpha: 0.5),
              dividerHandleColor: Colors.orange,
              minPanelRatio: 0.15,
              children: [
                _buildSamplePanel('Panel A', Colors.deepPurple),
                _buildSamplePanel('Panel B', Colors.green),
              ],
            ),
          ),
          const Divider(height: 20, thickness: 2),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Single Panel (no resizing):",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: ResizablePanelLayout(
              children: [_buildSamplePanel('Only Panel', Colors.redAccent)],
            ),
          ),
        ],
      ),
    );
  }
}
