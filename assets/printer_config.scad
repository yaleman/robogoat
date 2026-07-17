/*
  Shared printer envelope
  -----------------------
  Import this file with:

    include <printer_config.scad>

  Keep the safety margin non-zero so printable-part assertions do not rely on
  the slicer's exact edge or exclude skirts, brims, and dimensional variation.
*/

printer_name = "Bambu Lab X1C";
printer_bed_x = 256;
printer_bed_y = 256;
printer_bed_z = 256;
printer_bed_edge_margin = 3;

printer_usable_x = printer_bed_x - 2*printer_bed_edge_margin;
printer_usable_y = printer_bed_y - 2*printer_bed_edge_margin;
printer_usable_z = printer_bed_z - 2*printer_bed_edge_margin;

assert(
    printer_bed_x > 2*printer_bed_edge_margin,
    "Printer X envelope is invalid"
);
assert(
    printer_bed_y > 2*printer_bed_edge_margin,
    "Printer Y envelope is invalid"
);
assert(
    printer_bed_z > 2*printer_bed_edge_margin,
    "Printer Z envelope is invalid"
);
