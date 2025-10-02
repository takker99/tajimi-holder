// connector_cutout_backのテスト

include <BOSL2/std.scad>
include <prc03-21a10-7f_cutout_back.scad>

$fs=0.01; // Facet size for smoother curves
render()
diff("cutout") {
cuboid([23,23,3], anchor=BOTTOM)
  position(TOP) // 上面に配置
    tag("cutout") connector_cutout_back(3); // 厚み3mmの壁に対する切り欠き
}