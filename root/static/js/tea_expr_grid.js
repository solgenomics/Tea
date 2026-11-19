// Expression grid tab: a flat, read-only 2-D view of the expression of the query gene,
// with one column per stage and one row per tissue, each square coloured with the same
// colour scale as the expression cube. It is the figure the scatterplot tab uses as its
// sample selector, shown here on its own as an informational figure (no selection).
//
// Hovering a square shows the usual expression bar graphs (print_bar_chart, as in the
// cube's bar graph dialog) for that gene: the hovered stage across all tissues and the
// hovered tissue across all stages.

function draw_expression_grid(canvas,stage_names,tissue_names,gene_name,expr_by_stage_tissue,expr_unit,min_expr,max_expr) {

  var tile_w = 32;
  var tile_h = 24;
  var font_size = 14;
  var font_family = 'Helvetica';
  var hover_delay = 150; //ms the pointer must rest on a square before the bar graphs are drawn

  function clean(name) {
    return String(name).replace(/_/g, " ");
  }

  function text_width(txt, size, style) {
    return new Kinetic.Text({ text: txt, fontSize: size || font_size, fontStyle: style || 'normal', fontFamily: font_family }).width();
  }

  function is_nd(v) {
    return v == 0.000001 || v === undefined || v === null || v === "" || isNaN(v * 1);
  }

  function fmt(v) {
    v = v * 1;
    if (v >= 100) { return String(Math.round(v)); }
    return String(Math.round(v * 100) / 100);
  }

  // ---- grid geometry ----
  var max_tissue_w = 0;
  for (var t = 0; t < tissue_names.length; t++) {
    max_tissue_w = Math.max(max_tissue_w, text_width(clean(tissue_names[t])));
  }
  var max_stage_w = 0;
  for (var s = 0; s < stage_names.length; s++) {
    max_stage_w = Math.max(max_stage_w, text_width(clean(stage_names[s])));
  }

  var title_h = 34;
  var left = Math.ceil(max_tissue_w) + 20;
  var top = title_h + Math.ceil(max_stage_w) + 14;

  var title = "Expression of " + gene_name + (expr_unit ? " (" + expr_unit + ")" : "");
  var grid_w = left + stage_names.length * tile_w + 20;
  var canvas_w = Math.max(grid_w, text_width(title, 18, 'bold') + 40, 300);
  var canvas_h = top + tissue_names.length * tile_h + 20;

  canvas.width(canvas_w);
  canvas.height(canvas_h);

  var grid_layer = new Kinetic.Layer();
  var marker_layer = new Kinetic.Layer({ listening: false }); //outline of the hovered square

  grid_layer.add(new Kinetic.Text({
    x: 10, y: 8,
    text: title,
    fontSize: 18,
    fontStyle: 'bold',
    fontFamily: font_family,
    fill: 'black',
    listening: false
  }));

  //stage names on top, reading bottom to top
  for (var s = 0; s < stage_names.length; s++) {
    grid_layer.add(new Kinetic.Text({
      x: left + s * tile_w + (tile_w - font_size) / 2,
      y: top - 6,
      text: clean(stage_names[s]),
      fontSize: font_size,
      fontFamily: font_family,
      fill: 'black',
      rotation: 270,
      listening: false
    }));
  }

  //tissue names on the left, right aligned against the grid
  for (var t = 0; t < tissue_names.length; t++) {
    grid_layer.add(new Kinetic.Text({
      x: 5,
      y: top + t * tile_h + (tile_h - font_size) / 2 - 1,
      width: left - 15,
      align: 'right',
      text: clean(tissue_names[t]),
      fontSize: font_size,
      fontFamily: font_family,
      fill: 'black',
      listening: false
    }));
  }

  // ---- hover bar graphs: a floating panel next to the square ----
  var $pane = $(canvas.getContainer()); //the tab pane (#container_grid)
  $pane.css("position", "relative");

  var chart_a_w = Math.min(760, Math.max(340, tissue_names.length * 32 + 130)); //stage across tissues
  var chart_b_w = Math.min(520, Math.max(340, stage_names.length * 60 + 130));  //tissue across stages
  var chart_h = 270;
  var panel_w = Math.max(chart_a_w, chart_b_w) + 20;
  var panel_h = 30 + 2 * (chart_h + 26) + 10;

  $pane.css("min-height", (panel_h + 10) + "px");

  var $panel = $('<div id="grid_bar_hover"></div>').css({
    display: "none", position: "absolute", "z-index": 1000, "pointer-events": "none",
    background: "#fff", border: "1px solid #666", "border-radius": "6px",
    "box-shadow": "2px 2px 8px rgba(0,0,0,0.35)", padding: "6px 10px",
    width: panel_w + "px", "text-align": "left"
  });
  var $head = $('<div style="font-weight:bold;font-size:15px;margin-bottom:4px;"></div>');
  var $title_a = $('<div style="font-size:13px;font-weight:bold;margin-top:4px;"></div>');
  var $chart_a = $('<div id="gridhoverA_bar_graph"></div>').css({ width: chart_a_w + "px", height: chart_h + "px" });
  var $title_b = $('<div style="font-size:13px;font-weight:bold;margin-top:8px;"></div>');
  var $chart_b = $('<div id="gridhoverB_bar_graph"></div>').css({ width: chart_b_w + "px", height: chart_h + "px" });
  $panel.append($head, $title_a, $chart_a, $title_b, $chart_b);
  $pane.append($panel);

  var hover_timer = null;
  var hover_id = 0;

  function plot_hover_charts(s, t, value, x, y) {

    $head.text(clean(stage_names[s]) + " - " + clean(tissue_names[t]) + ": " +
               (is_nd(value) ? "ND" : fmt(value) + (expr_unit ? " " + expr_unit : "")));
    $title_a.text(clean(stage_names[s]) + " across tissues");
    $title_b.text(clean(tissue_names[t]) + " across stages");

    //keep the panel inside the pane horizontally and next to the hovered square
    var px = x + tile_w + 10;
    if (px + panel_w > $pane.width()) { px = x - panel_w - 10; }
    px = Math.max(0, px);
    var py = Math.max(0, y - 20);

    $panel.css({ left: px + "px", top: py + "px", display: "block" });

    //chart A: the hovered stage across all tissues (one series, one bar per tissue)
    $chart_a.empty();
    var sem_a = get_error_bars(gene_name, [stage_names[s]], tissue_names, 0);
    print_bar_chart(tissue_names, [stage_names[s]], [expr_by_stage_tissue[s].slice()], "gridhoverA", "", expr_unit, sem_a[0], sem_a[1], true);

    //chart B: the hovered tissue across all stages (one series, one bar per stage)
    $chart_b.empty();
    var tissue_col = [];
    for (var i = 0; i < stage_names.length; i++) { tissue_col.push(expr_by_stage_tissue[i][t]); }
    var sem_b = get_error_bars(gene_name, stage_names, [tissue_names[t]], 1);
    print_bar_chart(stage_names, [tissue_names[t]], [tissue_col], "gridhoverB", "", expr_unit, sem_b[0], sem_b[1], true);
  }

  function show_hover(tile, s, t, value) {
    marker_layer.removeChildren();
    marker_layer.add(new Kinetic.Rect({
      x: tile.x(), y: tile.y(), width: tile_w, height: tile_h,
      stroke: '#1a6ee0', strokeWidth: 3, listening: false
    }));
    marker_layer.draw();

    var my_id = ++hover_id;
    clearTimeout(hover_timer);
    hover_timer = setTimeout(function() {
      if (my_id === hover_id) { plot_hover_charts(s, t, value, tile.x(), tile.y()); }
    }, hover_delay);
  }

  function hide_hover() {
    hover_id++;
    clearTimeout(hover_timer);
    $panel.css("display", "none");
    marker_layer.removeChildren();
    marker_layer.draw();
  }

  function color_for(v) {
    if (is_nd(v)) { return 'rgb(210,210,210)'; }
    var rgb = get_expr_color(v, min_expr, max_expr);
    return 'rgb(' + rgb[0] + ',' + rgb[1] + ',' + rgb[2] + ')';
  }

  //expression squares
  for (var s = 0; s < stage_names.length; s++) {
    for (var t = 0; t < tissue_names.length; t++) {

      (function(s, t) {
        var value = expr_by_stage_tissue[s][t];

        var tile = new Kinetic.Rect({
          x: left + s * tile_w,
          y: top + t * tile_h,
          width: tile_w,
          height: tile_h,
          fill: color_for(value),
          stroke: 'rgb(50,50,50)',
          strokeWidth: 1
        });

        tile.on('mouseover', function() { show_hover(tile, s, t, value); });
        tile.on('mouseout', hide_hover);

        grid_layer.add(tile);
      })(s, t);
    }
  }

  canvas.add(grid_layer);
  canvas.add(marker_layer);
}
