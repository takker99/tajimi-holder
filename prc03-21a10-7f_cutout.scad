// --- コネクタの固定寸法 ---
flange_size = 21.0;
flange_thickness = 1.5;
center_hole_dia = 15.3;
mounting_hole_square_size = 16.0;
tolerance = 0.2; // 勘合のきつさを調整する公差


// PRC03-21A10-7F用の切り欠き形状を生成するモジュール
// ここでは Z=0 を「壁の表面」とみなし、+Z 方向に食い込む切り欠きを作る
module connector_cutout(thickness) {
    union() {
        // 1. フランジ用の四角い窪み（壁表面から奥へ）
        cuboid(
            [flange_size + tolerance, flange_size + tolerance, flange_thickness + tolerance],
            rounding=0.5,
            edges=["Z"],
            anchor=BOTTOM
        );

        // 2. コネクタ本体が通る中央の丸穴（余裕をみて十分な長さ）
        cylinder(d = center_hole_dia + tolerance, h = thickness*2, anchor=BOTTOM, $fn=100);

        // 3. 4つのM2.6ネジ穴（XYオフセットは translate を使用）
        let(pos = mounting_hole_square_size/2) {
            for (p = [[pos, pos], [-pos, pos], [pos, -pos], [-pos, -pos]]) {
                translate([p[0], p[1], 0])
                    screw_hole("M2.6", thread = true, l = thickness*2, anchor=BOTTOM);
            }
        }
    }
}