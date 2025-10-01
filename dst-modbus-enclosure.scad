// DST Modbus Enclosure for PRC03-21A10-7F Connectors
//
// This enclosure houses a 100x100mm PCB with 8 PRC03-21A10-7F connectors
// arranged in a 4x2 grid on the +X side panel.
//
// !! IMPORTANT !!
// This code requires the BOSL2 library.
// See: https://github.com/revarbat/BOSL2/wiki

include <BOSL2/std.scad>
include <BOSL2/screws.scad>
include <BOSL2/walls.scad>
include <prc03-21a10-7f_cutout.scad> // For connector_cutout module

// --- Design Parameters ---

// --- PCB Specifications ---
pcb_width = 100;           // PCB width (mm)
pcb_depth = 100;           // PCB depth (mm)
pcb_thickness = 1.5;       // PCB thickness (mm)
pcb_component_height = 18; // Maximum component height above PCB (mm)
pcb_clearance = 3;         // Clearance below PCB (mm)

// --- PCB Mounting Holes (M3) ---
// Distances from PCB edges
pcb_hole_x_offset = 6;     // Distance from X edges (mm)
pcb_hole_y_offset = 3.1;   // Distance from Y edges (mm)
pcb_hole_x_spacing = 85;   // Center-to-center X distance (mm)
pcb_hole_y_spacing = 90.8; // Center-to-center Y distance (mm)

// --- Enclosure Structure ---
wall_thickness = 4;        // Side wall thickness (mm)
bottom_thickness = 2;      // Bottom thickness (mm)
lid_thickness = 2;         // Lid thickness (mm)

// --- PRC03-21A10-7F Connector Specifications ---
connector_flange_size = 21;      // Flange size (21x21mm)
connector_depth = 26.5;          // Connector depth behind panel (mm)
connector_gap = 10;               // Gap between flanges (mm)
connector_rows = 2;              // Number of rows (vertical)
connector_cols = 4;              // Number of columns (horizontal)
connector_min_clearance = 20;    // Minimum distance from PCB (mm)

// --- Calculated Dimensions ---
// PCB position in enclosure
pcb_z_pos = bottom_thickness + pcb_clearance;

// Connector grid dimensions
connector_grid_width = connector_cols * connector_flange_size + (connector_cols - 1) * connector_gap;
connector_grid_height = connector_rows * connector_flange_size + (connector_rows - 1) * connector_gap;

// Enclosure internal dimensions
internal_width = pcb_width;
internal_depth = pcb_depth;
internal_height = max(
    pcb_clearance + pcb_thickness + pcb_component_height,
    connector_flange_size * connector_rows + connector_gap * (connector_rows - 1) + 10 * 2);

// Enclosure external dimensions
external_width = internal_width + 2 * wall_thickness + connector_min_clearance;
external_depth = internal_depth + wall_thickness + connector_depth;
external_height = internal_height + bottom_thickness + lid_thickness;

// --- USB Type-C Opening ---
usb_width = 20;            // USB opening width (mm)
usb_height = 10;           // USB opening height (mm)
usb_z_offset = 15;         // Height above PCB top surface (mm)

// --- Terminal Access Opening ---
terminal_width = 47;       // Terminal access width (mm)
terminal_height = 8;       // Terminal access height (mm)
terminal_x_offset = 14.4;  // Distance from PCB edge (mm)

// --- Chamfer ---
chamfer_size = 3;          // 3mm x 3mm 45-degree chamfer

include <gridfinity-rebuilt-openscad/src/core/standard.scad>
use <gridfinity-rebuilt-openscad/src/core/gridfinity-rebuilt-holes.scad>
use <gridfinity-rebuilt-openscad/src/core/base.scad>

// ===== PARAMETERS ===== //

/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;

/* [Base Hole Options] */
//Use gridfinity refined hole style. Not compatible with magnet_holes!
refined_holes = false;
// Base will have holes for 6mm Diameter x 2mm high magnets.
magnet_holes = true;
// Base will have holes for M3 screws.
screw_holes = true;
// Magnet holes will have crush ribs to hold the magnet.
crush_ribs = true;
// Magnet/Screw holes will have a chamfer to ease insertion.
chamfer_holes = true;
// Magnet/Screw holes will be printed so supports are not needed.
printable_hole_top = true;

hole_options = bundle_hole_options(refined_holes, magnet_holes, screw_holes, crush_ribs, chamfer_holes, printable_hole_top);

// ===== IMPLEMENTATION ===== //


// --- PCB Mounting Post Module ---
module pcb_mounting_post(height=pcb_clearance, hole_depth=6) {
    diff("pcb_post") {
        cylinder(h=height, d=6, $fn=16)
        tag("pcb_post") position(TOP) screw_hole("M2.6,4",anchor=TOP,thread=true);
    }
}

// --- Main Enclosure Body ---
module enclosure_body() {
        // --- Positive Geometry ---
        union() {
            // 5-sided box (bottom + 4 walls) built using BOSL2 attachments

            // Bottom plate - the foundation
            cuboid([external_width, external_depth, bottom_thickness], anchor=BOTTOM+FRONT) {

                // Left wall (-X side) attached to bottom's LEFT+TOP edge
                position(LEFT+TOP)
                    diff("prc03_cutouts_left") {
                        cuboid([wall_thickness, external_depth, external_height], anchor=BOTTOM+LEFT)
                        // PRC03-21A10-7F connector cutouts on +X face
                        tag("prc03_cutouts_left") position(LEFT) {
                          back(connector_flange_size)
                          grid_copies(spacing=connector_gap + connector_flange_size, n=[2,1], axes="yz") yrot(90) connector_cutout(wall_thickness * 1.1);
                        }
                    }

                // Right wall (+X side) attached to bottom's RIGHT+TOP edge
                position(RIGHT+TOP)
                    diff("prc03_cutouts") {
                        cuboid([wall_thickness, external_depth, external_height],
                              anchor=BOTTOM+RIGHT)
                        // PRC03-21A10-7F connector cutouts on +X face
                        tag("prc03_cutouts") position(RIGHT) {
                          grid_copies(spacing=connector_gap + connector_flange_size, n=[4,2], axes="yz") yrot(-90) connector_cutout(wall_thickness * 1.1);
                        }
                    }

                // Back wall (-Y side) attached to bottom's BACK+TOP edge
                position(FRONT+TOP) diff("usb_cutout") {
                    cuboid([external_width, wall_thickness, external_height],
                        anchor=BOTTOM+FRONT)
                    // USB Type-C opening on -Y face
                    tag("usb_cutout")
                      position(FRONT+BOTTOM)
                      up(usb_z_offset + pcb_thickness + pcb_clearance)
                      left(connector_min_clearance)
                      cuboid([usb_width, wall_thickness + 1, usb_height], anchor=FRONT+BOTTOM);
                }


                // Front wall (+Y side) attached to bottom's FRONT+TOP edge
                position(BACK+TOP) diff("terminal_cutout") {
                    cuboid([external_width, wall_thickness, external_height],
                        anchor=BOTTOM+BACK)
                    // Terminal access opening on +Y face
                    tag("terminal_cutout")
                      position(FRONT+BOTTOM)
                      up(pcb_thickness + pcb_clearance)
                      left(connector_min_clearance)
                      cuboid([terminal_width, wall_thickness + 1, terminal_height], anchor=FRONT+BOTTOM);
                }

                position(TOP+FRONT+LEFT)
                  translate([wall_thickness, wall_thickness, 0])
                  cuboid([pcb_width, pcb_depth, 0], anchor=TOP+FRONT+LEFT) // 位置合わせ用

                // PCB mounting posts attached to the bottom's TOP surface
                // position(TOP) makes z=0 be the top surface; translate X/Y from center
                position(TOP) {
                    for(x = [-1, 1]) for(y = [-1, 1]) {
                        translate([x * pcb_hole_x_spacing/2, y * pcb_hole_y_spacing/2, 0])
                            pcb_mounting_post();
                    }
                }

                position(BOTTOM)
                  down(7)
                  gridfinityBase(grid_size = [3, 3], hole_options = hole_options);

            }
        }

        // --- Negative Geometry ---

        // Main internal cavity

        // Snap-fit grooves
        // for(side = [-1, 1]) {
        //     translate([0, side * (external_depth/2 - wall_thickness/2), external_height - snap_tab_height/2])
        //         snap_groove();
        // }
}

// --- Snap-fit Parameters ---
snap_tab_width = 6;        // Width of snap tab (mm)
snap_tab_height = 2;       // Height of snap tab (mm)
snap_tab_thickness = 1;    // Thickness of snap tab (mm)
snap_groove_depth = 1.2;   // Depth of snap groove (mm)

// --- Snap-fit Tab Module ---
module snap_tab() {
    cuboid([snap_tab_width, snap_tab_thickness, snap_tab_height], anchor=BOTTOM);
}

// --- Snap-fit Groove Module ---
module snap_groove() {
    cuboid([snap_tab_width + 0.2, snap_groove_depth, snap_tab_height + 0.1], anchor=CENTER);
}

// --- Lid Module ---
module enclosure_lid() {
    union() {
        // Main lid
        cuboid([external_width - 0.2, external_depth - 0.2, lid_thickness],
               anchor=BOTTOM);

        // Lip that fits inside enclosure
        translate([0, 0, lid_thickness])
            cuboid([internal_width - 0.4, internal_depth - 0.4, 2],
                   anchor=BOTTOM);

        // Snap tabs on -Y and +Y sides
        for(side = [-1, 1]) {
            translate([0, side * (internal_depth/2 - 0.2), lid_thickness + 2])
                rotate([side > 0 ? 0 : 180, 0, 0])
                    snap_tab();
        }
    }
}


// --- Assembly ---
render()
// Main enclosure body
enclosure_body();

// Lid (translate up for visualization)
// translate([0, 0, external_height + 5])
//     enclosure_lid();

// --- Debug Information ---
echo("=== Enclosure Dimensions ===");
echo(str("External: ", external_width, " x ", external_depth, " x ", external_height, " mm"));
echo(str("Internal: ", internal_width, " x ", internal_depth, " x ", internal_height, " mm"));
echo(str("PCB Position: Z = ", pcb_z_pos, " mm"));
echo(str("Connector Grid: ", connector_grid_width, " x ", connector_grid_height, " mm"));
echo(str("Total Volume: ", (external_width * external_depth * external_height) / 1000, " cm³"));
