// ModbusボードのPCB穴配置テスト

include <BOSL2/std.scad>
include <BOSL2/screws.scad>
include <BOSL2/walls.scad>

// --- Design Parameters ---

// --- PCB Specifications ---
pcb_width = 100;           // PCB width (mm)
pcb_depth = 100;           // PCB depth (mm)
pcb_thickness = 1.5;       // PCB thickness (mm)
pcb_component_height = 18; // Maximum component height above PCB (mm)
pcb_clearance = 3;         // Clearance below PCB (mm)
pcb_hole_x_spacing = 85 + 0.25;   // Center-to-center X distance (mm)
pcb_hole_y_spacing = 92 + 0.5; // Center-to-center Y distance (mm)
pcb_hole_diameter = 3; // Mounting hole diameter (mm)


// --- PCB Mounting Post Module ---
module pcb_mounting_post() {
    cylinder(h=pcb_clearance+pcb_thickness, d=pcb_hole_diameter - 0.2 /* tolerance */);
}

$fs=0.01; // Facet size for smoother curves
render() // ちらつき防止
// ベース
// 材料節約のため、穴あきパネルを使用
diff("usb_text")
hex_panel(rect([pcb_width, pcb_depth], rounding=7.5),h=1.5, strut=1.5, spacing=10, frame=7) {
    position(TOP) // ベースの上面に配置する
    grid_copies(spacing=[pcb_hole_x_spacing, pcb_hole_y_spacing], n=[2,2]) // 上面中心を基準に2x2のグリッド配置
    pcb_mounting_post();

    tag("usb_text") position(TOP+FRONT) back(1) text3d("USB", h=0.5,size=5, anchor=TOP+FRONT);
}