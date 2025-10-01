// L-Bracket Test Mount for Tajimi SF-type Receptacle
//
// Rewritten using the BOSL2 library for clarity, simplicity, and power.
// Anchors are used for intuitive positioning, and screw_hole() creates perfect holes.
//
// !! IMPORTANT !!
// This code requires the BOSL2 library.
// See: https://github.com/revarbat/BOSL2/wiki

include <BOSL2/std.scad>
include <BOSL2/screws.scad>

// --- 主要パラメータ (Customize your bracket here) ---

// --- L字ブラケットの寸法 (mm) ---
base_width = 50;   // ブラケットの全体の幅
base_depth = 40;   // 底面の奥行き
wall_height = 40;  // 壁の高さ
thickness = 5;     // 全体の厚み

// --- 補強リブの寸法 (mm) ---
rib_size = 12;     // リブの直角二等辺三角形の一辺の長さ
rib_thickness = 2; // リブの厚み
// リブがコネクタに干渉しないように、中心からの距離を調整 (フランジ21mm角なので > 10.5)
rib_spacing = rib_thickness + 22;

// --- コネクタの固定寸法 (変更不要) ---
flange_size = 21.0;
flange_thickness = 1.5;
center_hole_dia = 15.3;
mounting_hole_square_size = 16.0;
tolerance = 0.2; // 勘合のきつさを調整する公差


// --- モジュール定義 ---

// コネクタ用の切り欠き形状を生成するモジュール
// ここでは Z=0 を「壁の表面」とみなし、+Z 方向に食い込む切り欠きを作る
module connector_cutout() {
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


// 直角二等辺三角形のリブ（ガセット）を内側コーナーに配置するモジュール
// apex(直角頂点)を y=0 の内側コーナー線上、z=thickness 付近に合わせ、
// y方向に両側へ僅かにオーバーラップさせて壁/底に確実に食い込ませる。
// 引数:
//  - x_off: コーナー線上のX位置（左右オフセット）。正で右側、負で左側。
//  - size: リブの脚長（壁方向・底方向の長さ）
//  - t:    リブの厚み（y方向の幅）
//  - eps:  すき間解消用の微小オーバーラップ量
module rib_gusset(size=rib_size, t=rib_thickness, eps=0.15) {
  rotate([90,0,90])
    linear_extrude(height=t, center=true)
      polygon([[0,0], [0, size + eps], [size + eps, 0]]);
}


// --- 本体生成 ---

difference() {
    // --- 1. ポジティブ形状 (ブラケットとリブ) ---
    union() {
        // L字ブラケット本体
        // 壁 (原点を底面の前面中央に)
        cuboid([base_width, thickness, wall_height], anchor=BOTTOM+BACK){
          // 補強リブ
          position(BOTTOM+BACK) // 中央を基準にする
          xcopies(rib_spacing) // X方向に左右対称に2個配置
          rib_gusset();

          // 底面 (原点を底面の前面中央に)
          position(BOTTOM+FRONT)
          cuboid([base_width, base_depth, thickness], anchor=TOP+FRONT);
        }
    }

    // --- 2. ネガティブ形状 (くり抜く部分) ---
    // 壁の前面中央に、コネクタ用の切り欠きモジュールを配置
    // connector_cutout() は +Z に食い込むので、+Z -> -Y になる回転をかけてから
    // 壁の位置(y=thickness)と高さ中央(z=wall_height/2)へ移動
    translate([0, -thickness, wall_height/2])
        rotate([-90,0,0])
            connector_cutout();

}